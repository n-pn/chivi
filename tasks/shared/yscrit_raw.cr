require "json"
require "./seed_util"

class CV::YscritRaw
  class Book
    include JSON::Serializable

    getter _id : Int64 = 0_i64

    @[JSON::Field(key: "bookId")]
    getter book_id : Int64 = 0_i64

    getter id : Int64 { _id > 0 ? _id : book_id }

    getter title : String
    getter author : String
  end

  struct User
    include JSON::Serializable

    getter _id : Int32

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  getter tags : Array(String) = [] of String

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_total : Int32 = 0

  # getter createdAt : Time # ignoring

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time?

  @[JSON::Field(key: "bookId")]
  getter book : Book

  @[JSON::Field(key: "createrId")]
  getter user : User

  def seed!(stime : Int64 = Time.utc.to_unix, yslist_id : Int64? = nil)
    yscrit = Yscrit.upsert!(self._id, self.created_at)

    yscrit.ysbook, yscrit.nvinfo = upsert_ysbook(self.book)
    yscrit.ysuser = Ysuser.upsert!(self.user.name, self.user._id)
    yscrit.yslist_id = yslist_id if yslist_id

    yscrit.stars = self.stars
    yscrit.set_tags(self.tags)
    yscrit.set_ztext(fix_ztext(ztext))

    yscrit.stime = stime
    yscrit.utime = (self.updated_at || self.created_at).to_unix

    yscrit.like_count = self.like_count if self.like_count > yscrit.like_count
    yscrit.repl_total = self.repl_total if self.repl_total > yscrit.repl_total

    yscrit.fix_sort!
    yscrit.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
  end

  ZTEXTS = Hash(String, Tabkv(String)).new do |h, k|
    h[k] = Tabkv(String).new("var/ysinfos/yscrits/#{k}-ztext.tsv")
  end

  def fix_ztext(input : String)
    return input unless input == "请登录查看评论内容"
    ZTEXTS[_id[0..3]][_id]? || "$$$"
  end

  def upsert_ysbook(book : Book)
    ysbook_id = book.id

    unless ysbook = Ysbook.find({id: ysbook_id})
      ysbook = Ysbook.new({id: ysbook_id})
      ysbook.btitle = book.title
      ysbook.author = book.author
    end

    btitle, author_zname = BookUtil.fix_names(book.title, book.author)
    author = Author.upsert!(author_zname)
    nvinfo = Nvinfo.upsert!(author, btitle)

    unless ysbook.nvinfo_id_column.defined?
      ysbook.nvinfo = nvinfo
      ysbook.save!
    end

    nvinfo.ysbook_id = ysbook_id unless nvinfo.ysbook_id == 0
    {ysbook, nvinfo}
  end

  #############

  alias BookComment = NamedTuple(comments: Array(self), total: Int32)
  alias ListComment = NamedTuple(books: Array(self), total: Int32)

  def self.from_book(json : String) : {Array(self), Int32}
    data = NamedTuple(data: BookComment).from_json(json)[:data]
    {data[:comments], data[:total]}
  end

  def self.from_list(json : String) : {Array(self), Int32}
    data = NamedTuple(data: ListComment).from_json(json)[:data]
    {data[:books], data[:total]}
  end
end
