require "db"
require "log"
require "json"
require "../../_util/text_util"

class YS::RawYsBook
  annotation Virtual; end

  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter id = 0

  @[JSON::Field(key: "title")]
  getter btitle = ""

  getter author = ""

  @[JSON::Field(key: "introduction")]
  getter intro = ""

  @[Virtual]
  @[JSON::Field(key: "classInfo")]
  getter class_info : NamedTuple(className: String)?

  @[JSON::Field(ignore: true)]
  getter genre = "其他"

  @[Virtual]
  @[JSON::Field(key: "tags")]
  getter tags = [] of String

  @[JSON::Field(ignore: true)]
  getter btags = ""

  getter cover = ""

  @[JSON::Field(key: "scorerCount")]
  getter voters : Int32 = 0

  @[Virtual]
  getter score = 0_f32

  @[JSON::Field(ignore: true)]
  getter rating : Int32 = 0

  @[Virtual]
  @[JSON::Field(key: "countWord")]
  getter word_count = 0_f64

  @[JSON::Field(ignore: true)]
  getter word_total = 0

  @[JSON::Field(key: "commentCount")]
  getter crit_total = 0

  @[JSON::Field(key: "addListTotal")]
  getter list_total = 0

  getter status = 0

  @[Virtual]
  getter shielded = false
  @[Virtual]
  getter recom_ignore = false

  @[JSON::Field(ignore: true)]
  getter shield : Int32 = 0

  @[Virtual]
  @[JSON::Field(key: "updateAt")]
  getter update_str : String = "2020-01-01T07:00:00.000Z"

  @[JSON::Field(ignore: true)]
  getter mtime : Int64 = 0_i64

  @[JSON::Field(ignore: true)]
  property origs : String = ""

  @[JSON::Field(ignore: true)]
  getter ctime : Int64 = Time.utc.to_unix

  def after_initialize
    @btitle = TextUtil.trim_spaces(@btitle)
    @author = TextUtil.trim_spaces(@author)

    @intro = TextUtil.split_html(@intro).join('\n')
    @btags = @tags.flat_map(&.split('-', remove_empty: true)).uniq!.join('\t')

    @genre = @class_info.try(&.[:className]) || "其他"
    @cover = fix_cover(@cover)

    @rating = (@score * 10).round.to_i

    @mtime = parse_time(@update_str).to_unix
    @shield = {@shielded, @recom_ignore}.map_with_index { |b, i| b ? 1 << i : 0 }.sum

    @word_total = fix_word_count(@word_count)
  end

  def changeset(@ctime : Int64 = Time.utc.to_unix)
    fields = [] of String
    values = [] of DB::Any

    {% for ivar in @type.instance_vars.reject(&.annotation(Virtual)) %}
      fields << {{ivar.name.stringify}}
      values << @{{ivar.name.id}}
    {% end %}

    {fields, values}
  end

  #############

  private def fix_cover(cover : String)
    return "" unless cover.starts_with?("http")
    return cover unless cover.includes?("qidian")

    cover
      .sub(/^http:/, "https:")
      .sub("image.qidian.com/books", "qidian.qpic.cn/qdbimg")
      .sub(/(\/180|\.jpg)$/, "/300")
  end

  private def parse_time(tstr : String)
    tstr = tstr.sub(/^0000/, "2020")
    time = Time.parse_utc(tstr, "%FT%T.%3NZ")
    time < Time.utc ? time : Time.utc
  rescue ex
    Log.error(exception: ex) { "error parsing time: #{ex.colorize.red}" }
    Time.utc(2021, 1, 1, 7, 0, 0)
  end

  private def fix_word_count(count : Float64, max = 100_000_000)
    count = count < max ? count : (count / 10000)
    count.round.to_i
  end

  ######################

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  class InvalidRaw < Exception; end

  alias YsbookJson = NamedTuple(bookInfo: RawYsBook, bookSource: Array(Source))

  DIR = "var/ysraw/books"

  def self.from_file(id : Int32)
    group = (id // 1000).to_s.rjust(3, '0')
    file = "#{DIR}/#{group}/#{id}.json"
    from_file(file)
  end

  def self.from_file(file : String) : self
    from_raw_json(File.read(file))
  rescue ex
    Log.error(exception: ex) { "parsing json file [#{file}] error: #{ex.body.message}" }
    raise InvalidRaw.new(file)
  end

  def self.from_raw_json(json : String) : self
    data = YsbookJson.from_json(json, root: "data")
    data[:bookInfo].tap(&.origs = data[:bookSource].map(&.link).join('\n'))
  end
end
