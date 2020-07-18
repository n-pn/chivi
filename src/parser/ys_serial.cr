require "json"

struct YsSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class YsSerial
  include JSON::Serializable

  property _id : Int32

  property title = ""
  property author = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?

  property tags = [] of String
  property cover = ""

  property status = 0_i32
  property shielded = false
  # property recom_ignore = false

  property countWord = 0_f32
  property commentCount = 0_i32

  property scorerCount = 0_i32
  property score = 0_f32

  property addListCount = 0_i32
  property addListTotal = 0_i32

  property updateAt = Time.utc(2000, 1, 1)
  property sources = [] of YsSource

  @[JSON::Field(ignore: true)]
  getter ysid : String { @_id.to_s }

  @[JSON::Field(ignore: true)]
  getter genre : String { @category.try(&.[:className]) || "" }

  @[JSON::Field(ignore: true)]
  getter origin_url : String { @sources.first?.try(&.link) || "" }

  @[JSON::Field(ignore: true)]
  getter fixed_tags : Array(String) { fix_tags }

  @[JSON::Field(ignore: true)]
  getter fixed_cover : String { fix_cover }

  @[JSON::Field(ignore: true)]
  getter mftime : Int64 { fix_time }

  @[JSON::Field(ignore: true)]
  getter voters : Int32 { @scorerCount }

  @[JSON::Field(ignore: true)]
  getter rating : Float32 { (@score * 10).round / 10 }

  @[JSON::Field(ignore: true)]
  getter weight : Int64 { (rating * 10).to_i64 * voters }

  @[JSON::Field(ignore: true)]
  getter word_count : Int32 { @countWord.round.to_i }

  @[JSON::Field(ignore: true)]
  getter crit_count : Int32 { @commentCount }

  private def fix_tags
    @tags.map(&.split("-")).flatten.uniq
  end

  private def fix_cover
    return "" unless @cover.starts_with?("http")
    @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
  end

  TIME_DF = Time.utc(2000, 1, 1).to_unix

  private def fix_time
    return TIME_DF if @updateAt >= Time.utc
    @updateAt.to_unix
  end

  alias Data = NamedTuple(bookInfo: YsSerial, bookSource: Array(YsSource))

  def self.load(file : String)
    text = File.read(file)
    return unless text.includes?("\"success\"")

    json = NamedTuple(data: Data).from_json(text)
    info = json[:data][:bookInfo]
    info.sources = json[:data][:bookSource]
    info
  end
end

# serial = YsSerial.load("var/.book_cache/yousuu/serials/176814.json").not_nil!
# puts serial.genre
# puts serial.fixed_tags
# puts serial.fixed_cover
# puts serial.mftime
