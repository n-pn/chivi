require "../../_util/post_util"

require "../_base"
require "../member/vi_user"
require "./dtopic"

class CV::Cvrepl
  include Clear::Model

  self.table = "cvrepls"
  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to cvpost : Cvpost, foreign_key_type: Int32

  column repl_cvrepl_id : Int32 = 0 # replied to cvrepl.id
  column repl_viuser_id : Int32 = 0 # replied to cvrepl's viuser.id

  column tagged_ids : Array(Int32) = [] of Int32

  column input : String = ""

  column ohtml : String = ""
  column otext : String = ""

  column state : Int32 = 0 # 0: normal, 1: highlight, -1: deleted, -2: removed
  column utime : Int64 = 0 # update when new post created/updated

  column edit_count : Int32 = 0 # edit count
  column like_count : Int32 = 0 # like count
  column repl_count : Int32 = 0 # repl count

  column coins : Int32 = 0 # reward given by users to this post

  timestamps

  scope :sort_by do |order|
    case order
    when "-id" then order_by(id: :desc)
    else            order_by(id: :asc)
    end
  end

  def set_input(input : String)
    self.utime = Time.utc.to_unix

    self.input = input
    self.ohtml = PostUtil.md_to_html(input)

    self.ohtml, self.tagged_ids = extract_user_ids(self.ohtml)
    self.otext = PostUtil.html_to_text(self.ohtml)
  end

  def extract_user_ids(input : String)
    users = [] of Int32

    output = input.gsub(/@\[(.+?)\]/) do |str|
      user = Viuser.load!($1)
      users << user.id
      "<cv-user>@[#{user.uname}]</cv-user>"
    rescue
      str
    end

    {output, users}
  end

  def set_dtrepl_id(dtrepl_id : Int32)
    self.repl_cvrepl_id = dtrepl_id

    if dtrepl_id > 0
      self.repl_viuser_id = Cvrepl.load!(dtrepl_id).viuser_id
    else
      self.repl_viuser_id = self.cvpost.viuser_id
    end
  end

  def update_content!(input : String)
    self.utime = Time.utc.to_unix
    self.set_input(input)
    self.save!
  end

  def soft_delete(admin = false)
    update!(state: admin ? -2 : -1)
  end

  def brief
    self.otext.split('\n', 2).first? || ""
  end

  def inc_like_count!(value = 1)
    self.like_count = self.like_count + value
    self.save!
  end

  #################

  CACHE = RamCache(Int32, self).new(1024, ttl: 20.minutes)

  def self.load!(id : Int32)
    CACHE.get(id) { find!({id: id}) }
  end
end
