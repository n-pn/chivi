require "json"

require "../utils/*"

struct CV::YsSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class CV::YsNvinfo
  alias Data = NamedTuple(bookInfo: YsNvinfo, bookSource: Array(YsSource))

  def self.load(file : String)
    text = File.read(file)
    return unless text.includes?("\"success\"")

    json = NamedTuple(data: Data).from_json(text)
    info = json[:data][:bookInfo]
    info.sources = json[:data][:bookSource]

    info
  end

  include JSON::Serializable

  getter _id : Int32
  getter y_nvid : String { _id.to_s }

  getter title = ""
  getter author = ""

  getter introduction = ""
  getter intro : Array(String) { TextUtils.split_html(introduction) }

  getter classInfo : NamedTuple(classId: Int32, className: String)?
  getter genre : String { @classInfo.try(&.[:className]) || "" }

  getter tags = [] of String
  getter tags_fixed : Array(String) { @tags.map(&.split("-")).flatten.uniq }

  getter cover = ""
  getter cover_fixed : String { get_fixed_cover }

  getter updateAt : Time = Time.utc(2020, 1, 1)
  getter updated_at : Time { @updateAt < Time.utc ? @updateAt : Time.utc(2020, 1, 1) }

  getter scorerCount = 0_i32
  getter voters : Int32 { scorerCount }

  getter score = 0_f32
  getter rating : Int32 { score.*(10).round.to_i }

  getter countWord = 0_f32
  getter word_count : Int32 { @countWord.round.to_i }

  getter commentCount = 0_i32
  getter crit_count : Int32 { @commentCount }

  getter status = 0_i32
  getter shielded = false
  # getter recom_ignore = false

  property sources = [] of CV::YsSource
  getter source : String { sources.first?.try(&.link) || "" }

  getter addListCount = 0_i32
  getter addListTotal = 0_i32

  private def get_fixed_intro
  end

  private def get_fixed_cover
    return "" unless @cover.starts_with?("http")
    @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
  end
end

# info = CV::YsNvinfo.load("_db/yousuu/.cache/infos/153426.json").not_nil!
# puts info.intro
# puts info.genre
# # puts info.tags_fixed
# # puts info.cover_fixed
# puts info.updated_at
# puts info.rating
