require "json"
require "./_seed_utils"

struct YsSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class YousuuInfo
  include JSON::Serializable

  getter _id : Int32
  getter y_bid : String { _id.to_s }

  property title = ""
  property author = ""

  getter introduction = ""
  getter intro : String { SeedUtils.clean_split(introduction).join("  ") }

  getter classInfo : NamedTuple(classId: Int32, className: String)?
  getter genre : String { @classInfo.try(&.[:className]) || "" }

  getter tags = [] of String
  getter tags_fixed : Array(String) { @tags.map(&.split("-")).flatten.uniq }

  getter cover = ""
  getter cover_fixed : String { get_fixed_cover }

  FALLBACK_TIME = Time.utc(2000, 1, 1)

  getter updateAt = Time.utc(2000, 1, 1)
  getter updated_at : Time { @updateAt < Time.utc ? @updateAt : FALLBACK_TIME }

  getter scorerCount = 0_i32
  getter voters : Int32 { scorerCount }

  getter score = 0_f32
  getter rating : Float32 { (score * 10).round / 10 }

  getter weight : Int32 { (Math.log(voters) * rating * 100).round.to_i }

  getter countWord = 0_f32
  getter word_count : Int32 { @countWord.round.to_i }

  getter commentCount = 0_i32
  getter crit_count : Int32 { @commentCount }

  getter status = 0_i32
  getter shielded = false
  # getter recom_ignore = false

  property sources = [] of YsSource
  getter source : String { sources.first?.try(&.link) || "" }

  getter addListCount = 0_i32
  getter addListTotal = 0_i32

  private def get_fixed_intro
  end

  private def get_fixed_cover
    return "" unless @cover.starts_with?("http")
    @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
  end

  alias Data = NamedTuple(bookInfo: YousuuInfo, bookSource: Array(YsSource))

  def self.load(file : String)
    text = File.read(file)
    return unless text.includes?("\"success\"")

    json = NamedTuple(data: Data).from_json(text)
    info = json[:data][:bookInfo]
    info.sources = json[:data][:bookSource]

    info
  end
end

# info = YousuuInfo.load("_db/seeds/yousuu/raw-infos/176814.json").not_nil!
# puts info.intro
# puts info.genre
# puts info.tags_fixed
# puts info.cover_fixed
# puts info.updated_at
