require "json"
require "./seed_util"

class CV::RawYsrepl
  class User
    include JSON::Serializable

    getter _id : Int64
    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String
  getter id : Int64 { _id[12..].to_i64(base: 16) }

  @[JSON::Field(key: "fromId")]
  getter user : User

  @[JSON::Field(key: "bookCommentId")]
  getter yscrit_id : String

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

  # getter createdAt : Time # ignoring

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  def seed!(bumped : Int64 = Time.utc.to_unix)
    if self.ztext == "请登录查看评论内容"
      return unless repl = Ysrepl.find({id: self.id})
    else
      repl = Ysrepl.get!(self.id, self.created_at)
    end

    return unless yscrit = Yscrit.find({origin_id: self.yscrit_id})
    ysuser = Ysuser.get!(self.user._id, self.user.name)

    repl.ysuser = ysuser
    repl.yscrit = yscrit

    repl.origin_id = self._id

    repl.ztext = self.ztext
    repl.vhtml = vhtml(yscrit.cvbook.bhash)

    repl.bumped = bumped

    repl.like_count = self.like_count
    repl.repl_count = self.repl_count

    repl.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
  end

  def vhtml(book : String)
    lines = self.ztext.split("\n").map(&.strip).reject(&.empty?)
    libcv = MtCore.generic_mtl(book)

    lines.map do |line|
      "<p>#{libcv.cv_plain(line, mode: 1).to_s}</p>"
    end.join("\n")
  end

  alias Data = NamedTuple(total: Int32, commentReply: Array(RawYsrepl))

  def self.parse_raw(data : String) : Tuple(Int32, Array(RawYsrepl))
    json = NamedTuple(data: Data).from_json(data)
    {json[:data][:total], json[:data][:commentReply]}
  end
end
