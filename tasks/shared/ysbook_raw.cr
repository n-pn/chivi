require "uri"
require "json"

require "../../src/_util/text_util"
require "../../src/_util/time_util"

class CV::YsbookRaw
  include JSON::Serializable

  getter _id : Int32
  getter snvid : String { _id.to_s }

  @[JSON::Field(key: "title")]
  getter btitle = ""
  getter author = ""

  getter introduction = ""
  getter bintro : Array(String) { TextUtil.split_html(introduction) }

  @[JSON::Field(key: "classInfo")]
  getter class_info : NamedTuple(classId: Int32, className: String)?
  getter klass : String { @class_info.try(&.[:className]) || "其他" }

  getter tags = [] of String
  getter genres : Array(String) { @tags.map(&.split("-")).flatten.unshift(klass).uniq }

  getter cover = ""
  getter bcover : String { fix_cover(@cover) }

  @[JSON::Field(key: "updateAt")]
  getter update_str : String = "2020-01-01T07:00:00.000Z"
  getter update_int : Int64 { parse_time(update_str).to_unix }

  @[JSON::Field(key: "scorerCount")]
  getter voters : Int32

  getter score = 0_f32
  getter rating : Int32 { score.*(10).round.to_i }

  @[JSON::Field(key: "countWord")]
  getter words = 0_f64
  getter word_count : Int32 { (words < 100_000_000 ? words : words / 10000).round.to_i }

  @[JSON::Field(key: "commentCount")]
  getter crit_count = 0_i32

  getter status = 0
  getter shielded = false
  getter shield : Int32 { shielded ? 1 : 0 }
  # getter recom_ignore = false

  property source = [] of Source

  getter pub_link : String { source[0]?.try(&.link) || "" }
  getter pub_name : String { extract_pub_name(pub_link) }

  @[JSON::Field(key: "addListCount")]
  getter list_count = 0_i32

  @[JSON::Field(key: "addListTotal")]
  getter list_total = 0_i32

  #############

  def fix_cover(cover : String)
    return "" unless cover.starts_with?("http")
    return cover unless cover.includes?("qidian")

    cover
      .sub(/^http:/, "https:")
      .sub("image.qidian.com/books", "qidian.qpic.cn/qdbimg")
      .sub(/(\/180|\.jpg)$/, "/300")
  end

  PUBS = {"yunqi", "chuangshi", "huayu", "yuedu", "shenqi"}

  def extract_pub_name(pub_link : String)
    return "" if pub_link.empty?
    return "" unless host = URI.parse(pub_link).host

    host = host.split(".")
    PUBS.includes?(host.first) ? host.first : host[-2]
  end

  EPOCH = Time.utc(2020, 1, 1, 7, 0, 0)

  def parse_time(update_str : String)
    tstr = update_str.sub(/^0000/, "2020")
    time = Time.parse_utc(tstr, "%FT%T.%3NZ")
    time < Time.utc ? time : Time.utc
  rescue err
    Log.error { "Error parsing time: #{err.colorize.red}" }
    EPOCH
  end

  ########################

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  class InvalidFile < Exception; end

  def self.parse_file(file : String) : self
    json = File.read(file)
    raise InvalidFile.new(file) unless json.starts_with?("{\"success")
    parse_json(json)
  end

  alias Data = NamedTuple(bookInfo: YsbookRaw, bookSource: Array(Source))

  def self.parse_json(json : String) : self
    json = NamedTuple(data: Data).from_json(json)
    info = json[:data][:bookInfo]
    info.source = json[:data][:bookSource]

    info
  end
end

# info = CV::YsBook.load("_db/yousuu/.cache/infos/153426.json").not_nil!
# puts info.intro
# puts info.genre
# # puts info.tags_fixed
# # puts info.cover_fixed
# puts info.updated_at
# puts info.rating
