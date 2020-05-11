require "json"
require "../../../src/_utils/unique_ids"

struct BookSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

struct YousuuInfo
  include JSON::Serializable

  property _id : Int32

  property title = ""
  property author = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?
  property genre = ""

  property tags = [] of String
  property cover = ""

  property status = 0
  property shielded = false

  property countWord = 0_f64
  property commentCount = 0

  property scorerCount = 0
  property score = 0_f64

  property updateAt = Time.utc

  property sources = [] of BookSource

  FIX_DIR = "tasks/books/fixes"
  FIX_MAP = Hash(String, String)
  TITLES  = FIX_MAP.from_json(File.read("#{FIX_DIR}/titles.json"))
  AUTHORS = FIX_MAP.from_json(File.read("#{FIX_DIR}/authors.json"))

  def fix_title!
    @title = @title.sub(/\(.+\)$/, "").strip
    @title = TITLES.fetch(@title, @title)
  end

  def fix_author!
    @author = @author.sub(/\(.+\)|.QD$/, "").strip
    @author = AUTHORS.fetch(@title, @author)
  end

  def fix_tags!
    @tags = @tags.map(&.split("-")).flatten.uniq
  end

  def fix_cover!
    if @cover.starts_with?("http")
      @cover = @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
    else
      @cover = ""
    end
  end
end

alias JsonData = NamedTuple(bookInfo: YousuuInfo, bookSource: Array(BookSource))
