require "../_util/post_util"

class CV::Dtpost
  include Clear::Model

  self.table = "dtposts"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dtopic : Dboard

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
end
