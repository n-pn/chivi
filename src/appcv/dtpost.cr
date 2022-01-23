require "../_util/post_util"

class CV::Dtpost
  include Clear::Model

  self.table = "dtposts"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dtopic : Dtopic

  column dt_id : Int32 = 0 # post index in the thread

  column repl_dtpost_id : Int64 = 0 # replied to dtpost.id
  column repl_cvuser_id : Int64 = 0 # replied to dtpost's cvuser.id

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
    topic ? where({dtopic_id: topic.id}) : with_dtopic
  end

  scope :filter_owner do |owner|
    owner ? where({cvuser_id: owner.id}) : with_cvuser
  end

  scope :sort_by do |order|
    case order
    when "tn"  then order_by(dt_id: :asc)
    when "-tn" then order_by(dt_id: :desc)
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

  def update_content!(params)
    utime = Time.utc.to_unix
    set_input(params["input"], params["itype"])

    if dtpost_id = params["dtpost"]?.try(&.to_i64)
      self.repl_dtpost_id = dtpost_id
      self.repl_cvuser_id = Dtpost.load!(dtpost_id).cvuser.id
    end

    self.save!
  end

  def solf_delete(admin = false)
    update!(state: admin ? -2 : -1)
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 20.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) }
  end
end
