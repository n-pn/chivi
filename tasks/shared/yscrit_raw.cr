require "json"
require "./seed_util"

module CV::YscritRaw
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

  class Json
    include JSON::Serializable

    getter _id : String
    getter id : Int64 { _id[12..].to_i64(base: 16) }

    @[JSON::Field(key: "score")]
    getter stars : Int32 = 3

    @[JSON::Field(key: "content")]
    property ztext : String = ""

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

    alias Data = NamedTuple(total: Int32, comments: Array(Json))

    def self.parse_list(data : String) : Array(self)
      json = NamedTuple(data: Data).from_json(data)
      json[:data][:comments]
    end
  end

  extend self

  def seed!(json : Json, bumped : Int64 = Time.utc.to_unix)
    crit = Yscrit.get!(json.id, json.created_at)

    return unless ysbook = Ysbook.find({id: json.book._id})
    ysuser = Ysuser.get!(json.user._id, json.user.name)
    cvbook = ysbook.cvbook

    crit.ysuser = ysuser
    crit.ysbook = ysbook
    crit.cvbook = cvbook

    crit.origin_id = json._id
    crit.stars = json.stars

    unless json.ztext.empty? || json.ztext == "请登录查看评论内容"
      crit.ztext = json.ztext
      crit.vhtml = SeedUtil.cv_ztext(json.ztext, cvbook.bhash)
    end

    crit.bumped = bumped
    crit.mftime = json.updated_at.to_unix

    crit.like_count = json.like_count
    crit.repl_count = json.repl_count

    crit.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
  end
end
