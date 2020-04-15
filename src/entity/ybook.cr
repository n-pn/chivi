require "json"

# Book info from yousuu
class YBook
  class Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  include JSON::Serializable

  property _id : Int32
  property label = ""

  property title : String = ""
  property author : String = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?
  property genre = ""

  property tags = [] of String
  property cover = ""

  property covers = [] of String

  property status = 0

  property shielded = false
  property hidden = 0

  @[JSON::Field(key: "countWord")]
  property word_count = 0_f64

  @[JSON::Field(key: "commentCount")]
  property review_count = 0

  @[JSON::Field(key: "scorerCount")]
  property votes = 0
  property score = 0_f64
  property tally = 0_f64

  @[JSON::Field(key: "updateAt")]
  property updated_at = Time.utc
  property mtime = 0_i64

  property yousuu_bids = [] of Int32
  property source_urls = [] of String

  DIR = "src/entity/data"
  MAP = Hash(String, String)

  TITLES  = MAP.from_json(File.read("#{DIR}/fix-titles.json"))
  AUTHORS = MAP.from_json(File.read("#{DIR}/fix-authors.json"))

  alias Data = NamedTuple(bookInfo: YBook, bookSource: Array(Source))

  def self.load(text : String)
    json = NamedTuple(data: Data).from_json(text)
    info = json[:data][:bookInfo]

    if title = TITLES[info.title || ""]?
      info.title = title
    end

    if author = info.author
      if fixed_author = AUTHORS[info.title || ""]?
        info.author = fixed_author
      else
        info.author = author.sub(".QD", "").strip
      end
    end

    info.label = "#{info.title}--#{info.author}"

    if genre = info.category
      info.genre = genre[:className]
    end

    info.tags = info.tags.map(&.split("-")).flatten

    if info.cover.starts_with?("http")
      info.covers << fix_cover_url(info.cover)
    end

    info.hidden = info.shielded ? 2 : 0

    info.tally = (info.votes * info.score * 2).round / 2
    info.mtime = info.updated_at.to_unix_ms

    info.yousuu_bids = [info._id]
    info.source_urls = json[:data][:bookSource].map(&.link)

    info
  end

  def self.fix_cover_url(cover)
    case cover
    when .starts_with?("http://image.qidian.com")
      cover
        .sub("http://image.qidian.com/books", "https://qidian.qpic.cn/qdbimg")
        .sub("/300", "/300.jpg")
    else
      cover
    end
  end

  def merge(other : YBook)
    @intro = other.intro if @intro.empty?
    if @genre.empty?
      @genre = other.genre
    else
      @tags << other.genre unless other.genre.empty?
    end

    @tags.concat(other.tags).uniq!

    @covers << other.cover
    @covers.uniq!

    @votes += other.votes
    @tally += other.tally
    @score = (@tally * 10 / @votes).round / 10 if @votes > 0

    @source_urls.concat(other.source_urls)
    @source_urls.uniq!
  end
end
