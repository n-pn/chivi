require "./_raw_base"

class ZR::RawTubook
  include JSON::Serializable

  @[JSON::Field(key: "book_id")]
  getter id : Int32

  # getter author_id : Int32

  @[JSON::Field(key: "title")]
  getter btitle = ""

  @[JSON::Field(key: "author_nickname")]
  getter author = ""

  getter cover = ""

  @[JSON::Field(key: "info")]
  getter intro = ""

  @[JSON::Field(key: "second_type_name")]
  getter genre = "其他"

  @[JSON::Field(key: "tag")]
  getter btags = [] of String

  @[JSON::Field(key: "third_type_name")]
  getter subgenre = ""

  @[JSON::Field(key: "score_people_number")]
  getter voters : Int32 = 0

  getter score = ""

  @[JSON::Field(ignore: true)]
  getter rating : Int32 { (@score.to_f * 10).round.to_i }

  @[JSON::Field(key: "word_number")]
  getter word_count = 0

  @[JSON::Field(key: "chapter_number")]
  getter chap_count = 0

  @[JSON::Field(key: "process_name")]
  getter status_str = ""

  @[JSON::Field(key: "source_name")]
  getter origin_name = ""

  def after_initialize
    @btitle = TextUtil.trim_spaces(@btitle)
    @author = TextUtil.trim_spaces(@author)

    @intro = TextUtil.split_html(@intro).join('\n')
  end

  def status : Int32
    case @status_str
    when "连载" then 0
    when "完结" then 1
    when "断更" then 2
    else
      puts @status_str
      3
    end
  end
end

struct ZR::RawTubookList
  include JSON::Serializable

  @[JSON::Field(key: "data")]
  getter books : Array(RawTubook)

  getter total : Int32

  def self.from_json(io_or_string : String | IO)
    parser = JSON::PullParser.new(io_or_string)
    parser.on_key!("data") { new(parser) }
  end
end
