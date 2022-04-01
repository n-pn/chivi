require "../_util/post_util"

class CV::Cvrepl
  include Clear::Model

  self.table = "cvrepls"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to cvpost : Cvpost

  column ii : Int32 = 0 # post index in the thread

  column repl_cvrepl_id : Int64 = 0 # replied to cvrepl.id
  column repl_cvuser_id : Int64 = 0 # replied to cvrepl's cvuser.id
  getter parent : Cvrepl { Cvrepl.load!(repl_cvrepl_id) }

  column tagged_ids : Array(Int64) = [] of Int64

  column input : String = ""
  column itype : String = "md"

  column ohtml : String = ""
  column otext : String = ""

  column state : Int32 = 0 # 0: normal, 1: highlight, -1: deleted, -2: removed
  column utime : Int64 = 0 # update when new post created/updated

  column edit_count : Int32 = 0 # edit count
  column like_count : Int32 = 0 # like count
  column repl_count : Int32 = 0 # repl count

  column coins : Int32 = 0 # reward given by users to this post

  timestamps

  scope :filter_topic do |topic|
    topic ? where({cvpost_id: topic.id}) : with_cvpost
  end

  scope :filter_owner do |owner|
    owner ? where({cvuser_id: owner.id}) : with_cvuser
  end

  scope :sort_by do |order|
    case order
    when "tn"  then order_by(ii: :asc)
    when "-tn" then order_by(ii: :desc)
    when "-id" then order_by(id: :desc)
    else            order_by(id: :asc)
    end
  end

  def set_input(input : String, itype = "md")
    self.utime = Time.utc.to_unix

    self.input = input
    self.itype = itype
    self.ohtml = PostUtil.md_to_html(input)

    self.ohtml, self.tagged_ids = extract_user_ids(self.ohtml)
    self.otext = PostUtil.html_to_text(self.ohtml)
  end

  def extract_user_ids(input : String)
    users = [] of Int64

    output = input.gsub(/@\[(.+?)\]/) do |str|
      user = Cvuser.load!($1)
      users << user.id
      "<cv-user>@[#{user.uname}]</cv-user>"
    rescue
      str
    end

    {output, users}
  end

  def set_dtrepl_id(dtrepl_id : Int64)
    self.repl_dtpost_id = dtrepl_id
    self.repl_cvuser_id = Cvrepl.load!(dtrepl_id).cvuser_id
  end

  def update_content!(params)
    self.utime = Time.utc.to_unix
    set_input(params["input"], params["itype"])
    self.save!
  end

  def soft_delete(admin = false)
    update!(state: admin ? -2 : -1)
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 20.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) }
  end
end
