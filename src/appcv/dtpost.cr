require "cmark"

class CV::Dtpost
  include Clear::Model

  self.table = "dtposts"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dtopic : Dboard

  column tagged_ids : Array(Int64) = [] of Int64

  column dt_id : Int32 = 0

  column input : String = ""
  column itype : String = "md"

  column ohtml : String = ""
  column odesc : String = ""

  column state : Int32 = 0 # 0: normal, 1: highlight, -1: deleted, -2: removed
  column utime : Int64 = 0 # update when new post created

  column edits : Int32 = 0 # edit count
  column likes : Int32 = 0 # like count
  column award : Int32 = 0 # karma given by users to this post

  timestamps

  OPTS = Cmark::Option.flags(Hardbreaks, ValidateUTF8, FullInfoString)

  def set_input(input : String, itype = "md")
    self.input = input
    self.itype = itype
    self.ohtml = Cmark.gfm_to_html(input, OPTS)

    self.ohtml, self.tagged_ids = extract_user_ids(self.ohtml)
    self.odesc = extract_desc(self.ohtml)
  end

  def extract_user_ids(input : String)
    users = [] of Int64

    input = input.gsub(/@\[(.+?)\]/) do |str|
      users << Cvuser.load!($1).id
      "<cv-user>@#{$1}</cv-user>"
    rescue
      str
    end

    {input, users}
  end

  DESC_RE = Regex.new("<p>(.+)<\\/p>", :multiline)

  def extract_desc(input : String)
    return "" unless match = DESC_RE.match(input)
    match[1]
  end
end
