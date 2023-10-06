require "./_yousuu"

class RawYsbook
  annotation Temp; end

  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter id : Int32

  @[JSON::Field(key: "title")]
  getter btitle = ""

  getter author = ""

  getter cover = ""

  @[JSON::Field(key: "introduction")]
  getter intro = ""

  @[JSON::Field(key: "className", root: "classInfo")]
  getter genre = "其他"

  @[JSON::Field(key: "tags")]
  getter btags = [] of String

  @[JSON::Field(key: "scorerCount")]
  getter voters : Int32 = 0

  @[Temp]
  getter score = 0_f32

  @[JSON::Field(ignore: true)]
  getter rating : Int32 { (@score * 10).round.to_i }

  @[Temp]
  @[JSON::Field(key: "countWord")]
  getter raw_word_count = 0_f64

  @[JSON::Field(ignore: true)]
  getter word_count : Int32 do
    raw_count = raw_word_count.round.to_i64
    (raw_count < 100_000_000 ? raw_count : raw_count // 10000).to_i
  end

  @[JSON::Field(key: "commentCount")]
  getter crit_count = 0

  @[JSON::Field(key: "addListTotal")]
  getter list_count = 0

  getter status = 0

  @[Temp]
  getter? shielded = false

  @[Temp]
  getter? recom_ignore = false

  @[JSON::Field(ignore: true)]
  getter shield : Int32 { (@shielded ? 1 : 0) & (@recom_ignore ? 2 : 0) }

  @[Temp]
  @[JSON::Field(key: "updateAt")]
  getter update_str : String = "2020-01-01T07:00:00.000Z"

  @[JSON::Field(ignore: true)]
  getter book_mtime : Int64 { parse_time(@update_str).to_unix }

  @[JSON::Field(ignore: true)]
  property info_rtime : Int64 = Time.utc.to_unix

  @[JSON::Field(ignore: true)]
  property sources = [] of String

  def after_initialize
    @btitle = TextUtil.clean_and_trim(@btitle)
    @author = TextUtil.clean_and_trim(@author)

    @intro = TextUtil.split_html(@intro).join('\n')
    @btags = @btags.flat_map(&.split('-', remove_empty: true)).uniq!

    @cover = fix_cover(@cover)
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

  ######################

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  struct YsbookJson
    include JSON::Serializable

    @[JSON::Field(key: "bookInfo")]
    getter info : RawYsbook

    @[JSON::Field(key: "bookSource")]
    property sources : Array(Source)
  end

  def self.from_json(io_or_string : String | IO)
    parser = JSON::PullParser.new(io_or_string)

    parser.on_key!("data") do
      data = YsbookJson.new(parser)
      data.info.sources = data.sources.map(&.link)
      data.info
    end
  end
end
