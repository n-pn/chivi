require "json"
require "../../_utils/unique_ids"

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
  property recom_ignore = false

  property countWord = 0_f64
  property commentCount = 0

  property scorerCount = 0
  property score = 0_f64

  property addListCount = 0
  property addListTotal = 0

  property updateAt = Time.local(2010, 1, 1)

  property sources = [] of BookSource

  FIX_DIR = "src/bookdb/_fixes"
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

# text = File.read("data/.inits/txt-inp/yousuu/serials/176814.json")
# data = NamedTuple(data: JsonData).from_json(text)

# pp data
