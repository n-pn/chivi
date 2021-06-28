require "uri"
require "json"

require "../../src/cutil/*"

class CV::YsbookOg
  include JSON::Serializable

  getter _id : Int32
  getter ynvid : String { _id.to_s }

  getter title = ""
  getter author = ""

  getter introduction = ""
  getter intro : Array(String) { TextUtils.split_html(introduction) }

  getter classInfo : NamedTuple(classId: Int32, className: String)?
  getter klass : String { @classInfo.try(&.[:className]) || "" }

  getter tags = [] of String
  getter tags_fixed : Array(String) { @tags.map(&.split("-")).flatten.uniq }

  getter cover = ""
  getter cover_fixed : String { get_fixed_cover }

  getter updateAt : String = "2020-01-01T07:00:00.000Z"

  getter updated_at : Time do
    tstr = updateAt.sub("0000", "2020")
    time = Time.parse_utc(tstr, "%FT%T.%3NZ")
    time < Time.utc ? time : Time.utc
  rescue err
    puts err.colorize.red
    Time.utc(2020, 1, 1, 7, 0, 0)
  end

  getter scorerCount = 0_i32
  getter voters : Int32 { scorerCount }

  getter score = 0_f32
  getter rating : Int32 { score.*(10).round.to_i }

  getter countWord = 0_f64
  getter word_count : Int32 {
    count = countWord < 100_000_000 ? countWord : (countWord / 10000)
    count.round.to_i
  }

  getter commentCount = 0_i32

  getter status = 0
  getter shielded = false
  # getter recom_ignore = false

  property source = [] of Source
  getter root_link : String { source[0]?.try(&.link) || "" }

  getter root_name : String { extract_hostname(root_link) }

  private def extract_hostname(link : String)
    return "" if link.empty?
    return "" unless host = URI.parse(link).host

    host = host.split(".")

    case host.first
    when "yunqi", "chuangshi", "huayu", "yuedu", "shenqi"
      return host.first.capitalize
    else
      host[-2]
    end
  end

  getter addListCount = 0_i32
  getter addListTotal = 0_i32

  getter genres : Array(String) do
    tags = tags_fixed.reject { |x| x == author || x == title }
    [klass].concat(tags).uniq
  end

  def decent?
    addListTotal > 0 || commentCount > 4
  end

  private def get_fixed_cover
    return "" unless @cover.starts_with?("http")
    @cover.sub("http://image.qidian.com/books", "http://qidian.qpic.cn/qdbimg")
  end

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  alias Data = NamedTuple(bookInfo: YsbookOg, bookSource: Array(Source))

  class InvalidFile < Exception; end

  def self.load(file : String) : self
    text = File.read(file)
    raise InvalidFile.new(file) unless text.includes?("\"success\"")

    json = NamedTuple(data: Data).from_json(text)
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
