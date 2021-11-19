require "json"
require "./seed_util"

class CV::RawYscrit
  class Book
    include JSON::Serializable
    getter _id : Int64
    getter title : String
    getter author : String
  end

  class User
    include JSON::Serializable

    getter _id : Int64
    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String
  getter id : Int64 { _id[12..].to_i64(base: 16) }

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

  # getter createdAt : Time # ignoring

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time

  @[JSON::Field(key: "bookId")]
  getter book : Book

  @[JSON::Field(key: "createrId")]
  getter user : User

  def seed!(bumped : Int64 = Time.utc.to_unix)
    if self.ztext == "请登录查看评论内容"
      return unless crit = Yscrit.find({id: self.id})
    else
      crit = Yscrit.get!(self.id, self.created_at)
    end

    return unless ysbook = Ysbook.find({id: self.book._id})
    ysuser = Ysuser.get!(self.user._id, self.user.name)
    cvbook = ysbook.cvbook

    crit.ysuser = ysuser
    crit.ysbook = ysbook
    crit.cvbook = cvbook

    crit.origin_id = self._id

    crit.stars = self.stars
    crit.ztext = self.ztext
    crit.vhtml = vhtml(cvbook.bhash)

    crit.bumped = bumped
    crit.mftime = self.updated_at.to_unix

    crit.like_count = self.like_count
    crit.repl_count = self.repl_count

    crit.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
  end

  def vhtml(book : String)
    lines = self.ztext.split("\n").map(&.strip).reject(&.empty?)
    cvmtl = MtCore.generic_mtl(book)

    lines.map do |line|
      "<p>#{cvmtl.cv_plain(line, mode: 1).to_s}</p>"
    end.join("\n")
  end

  alias Data = NamedTuple(total: Int32, comments: Array(RawYscrit))

  def self.parse_raw(data : String)
    json = NamedTuple(data: Data).from_json(data)
    json[:data][:comments]
  end
end
