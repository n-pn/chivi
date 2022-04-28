require "json"
require "./seed_util"

class CV::YscritRaw
  class Book
    include JSON::Serializable

    getter _id : Int64 = 0_i64

    @[JSON::Field(key: "bookId")]
    getter book_id : Int64 = 0_i64

    getter id : Int64 { _id > 0 ? id : book_id }

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
  getter id : Int64 { _id[12..].to_i64(base: 16) }

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  property ztext : String = ""

  getter tags : Array(String) = [] of String

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

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
    crit = Yscrit.get!(self.id, self.created_at)

    crit.ysbook, crit.nvinfo = upsert_ysbook(self.book)
    crit.ysuser = Ysuser.upsert!(self.user.name, self.user._id)

    crit.origin_id = self._id
    crit.yslist_id = yslist_id if yslist_id

    crit.stars = self.stars
    crit.set_tags(self.tags)
    crit.set_body(self.ztext)

    crit.stime = stime
    crit.utime = (self.updated_at || self.created_at).to_unix

    crit.like_count = self.like_count
    crit.repl_total = self.repl_count
    crit.update_sort!

    crit.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
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

  # record BookComment, total : Int32, comments : Array(self) do
  #   include JSON::Serializable
  # end

  alias BookComment = NamedTuple(total: Int32, comments: Array(self))
  alias ListComment = NamedTuple(total: Int32, books: Array(self))

  def self.from_book(data : String) : BookComment
    json = NamedTuple(data: BookComment).from_json(data)
    json[:data]
  end

  def self.from_list(data : String) : ListComment
    json = NamedTuple(data: ListComment).from_json(data)
    json[:data]
  end
end
