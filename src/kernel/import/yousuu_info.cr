require "json"

struct BookSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class YousuuInfo
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
  # property recom_ignore = false

  property countWord = 0_f64
  property commentCount = 0

  property scorerCount = 0
  property score = 0_f64

  # property addListCount = 0
  # property addListTotal = 0

  property updateAt = Time.utc(2000, 1, 1)
  property sources = [] of BookSource

  FIXING  = Hash(String, String)
  TITLES  = FIXING.from_json(File.read("etc/bookdb/fix-titles.json"))
  AUTHORS = FIXING.from_json(File.read("etc/bookdb/fix-authors.json"))

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

  ROOT = File.join("var", "appcv", ".cache", "yousuu", "serials")

  def glob!
    Dir.glob(File.join(ROOT, "*.json"))
  end

  alias Data = NamedTuple(bookInfo: YousuuInfo, bookSource: Array(BookSource))

  def self.load!(file : String)
    text = File.read(file)
    json = NamedTuple(data: Data).from_json(text)

    info = json[:data][:bookInfo]
    info.sources = json[:data][:bookSource]

    info.fix_title!
    info.fix_author!

    info
  end
end

# pp YousuuInfo.load!("var/appcv/.cache/yousuu/serials/176814.json")
