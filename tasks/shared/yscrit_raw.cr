require "json"
require "./seed_util"
require "../../src/ysweb/models/*"

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

  def seed!(stime : Int64 = Time.utc.to_unix, yslist_id : Int64? = nil) : Nil
    self.save_ztext
    # TODO: also save infos

    yscrit = YS::Yscrit.upsert!(self._id, self.created_at)

    yscrit.ysbook, yscrit.nvinfo = upsert_ysbook(self.book)
    yscrit.ysuser = YS::Ysuser.upsert!(self.user.name, self.user._id)
    yscrit.yslist_id = yslist_id if yslist_id

    yscrit.stars = self.stars
    yscrit.set_tags(self.tags, force: true) unless self.tags.empty?
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

  ZTEXT_DIR = "var/ys_db/crits"

  def save_ztext
    # save crit body to disk instead of db
    # work in progress
    # TODO: remove ztext field in db and use zip files insteads

    # do not write file if content is hidden in yousuu
    return if ztext == "请登录查看评论内容" || ztext.empty?

    # write crit body to {yousuu_id}.zip
    # NOTE: were are using yousuu_id instead of yscrit id prefix
    # so that we can easy look for the custom dict name for the machine translation
    # also to detect some garbage spam reviews (which is already removed from yousuu)

    ztext_dir = "#{ZTEXT_DIR}/#{book.id}"
    Dir.mkdir_p(ztext_dir)

    text_path = "#{ztext_dir}/#{_id}.txt"
    File.write(text_path, ztext)

    # add file to zip
    # do not delete added file yet in case the zip file is overridded
    # TODO: delete file
    `zip -jq "#{ztext_dir}.zip" "#{text_path}"`
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

    btitle_zh, author_zh = BookUtil.fix_names(book.title, book.author)
    nvinfo = Nvinfo.upsert!(author_zh, btitle_zh)

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

  def self.from_json(json : String, type = :book)
    type == :book ? from_book(json) : from_list(json)
  end
end
