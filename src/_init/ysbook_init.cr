require "json"

class CV::YsbookInit
  INP_DIR = "_db/yousuu/infos"
  OUT_DIR = "db/seed_data/ysbooks"

  def self.map_path(ynvid : Int32)
    group = (ynvid // 1000).to_s
    "#{group.rjust(3, '0')}/#{ynvid}.json"
  end

  def self.inp_path(ynvid : Int32)
    File.join(INP_DIR, map_path(ynvid))
  end

  def self.out_path(ynvid : Int32)
    File.join(OUT_DIR, map_path(ynvid))
  end

  def self.load(ynvid : Int32, mode = 0)
    inp_file = self.inp_path(ynvid)
    inp_time = FileUtil.mtime_int(inp_file)

    out_file = self.out_path(ynvid)
    out_time = FileUtil.mtime_int(out_file)

    if (mode == 2 && inp_time > 0) || (inp_time > out_time)
      self.new(Parser.parse_file(inp_file)).tap(&.save!(inp_time &+ 60))
    elsif mode == 1 && out_time > 0
      self.from_json(File.read(out_file))
    else
      nil
    end
  rescue YsbookInit::InvalidJSON
    return
  end

  ####################
  include JSON::Serializable

  getter _id = 0

  property btitle = ""
  property author = ""

  getter bcover = ""
  getter bintro = [] of String
  getter genres = [] of String

  getter status = 0
  getter shield = 0

  getter update_str = ""
  getter update_int = 0_i64

  getter voters = 0
  getter rating = 0

  getter word_count = 0
  getter crit_count = 0
  getter list_count = 0

  getter pub_link = ""
  getter pub_name = ""

  getter stime = 0_i64

  def initialize(parser : Parser)
    @_id = parser._id

    @btitle = parser.title
    @author = parser.author

    parser.class_info.try { |x| @genres << x[:className] }
    parser.tags.each { |tag| @genres.concat(tag.split('-')) }
    @genres.uniq!

    @bintro = fix_intro(parser.introduction)
    @bcover = fix_cover(parser.cover)

    @status = parser.status
    @shield = parser.shielded ? 1 : 0

    @update_str = parser.update_str
    @update_int = fix_utime(@update_str).to_unix

    @voters = parser.scorer_count
    @rating = parser.score.*(10).round.to_i

    @word_count = fix_word_count(parser.count_word)
    @crit_count = parser.comment_count
    @list_count = parser.list_count

    @pub_link = parser.source[0]?.try(&.link) || ""
    @pub_name = extract_pub_name(@pub_link)
  end

  def save!(@stime : Int64 = Time.utc.to_unix) : Nil
    out_file = YsbookInit.out_path(_id)
    FileUtils.mkdir_p(File.dirname(out_file))
    File.write(out_file, self.to_pretty_json)

    utime = Time.unix(stime)
    File.utime(utime, utime, out_file)
  end

  def good?
    return false if @btitle.blank? || @author.blank?
    @list_count > 2 || @crit_count > 4
  end

  # ###### fix data

  def fix_intro(intro : String)
    TextUtil.split_html(intro)
  end

  def fix_cover(cover : String)
    return "" unless cover.starts_with?("http")
    return cover unless cover.includes?("qidian")

    cover
      .sub(/^http:/, "https:")
      .sub("image.qidian.com/books", "qidian.qpic.cn/qdbimg")
      .sub(/(\/180|\.jpg)$/, "/300")
  end

  EPOCH = Time.utc(2020, 1, 1, 7, 0, 0)

  def fix_utime(utime : String)
    tstr = utime.sub(/^0000/, "2020")
    time = Time.parse_utc(tstr, "%FT%T.%3NZ")
    time < Time.utc ? time : Time.utc
  rescue err
    puts "error parsing time: #{err.colorize.red}"
    EPOCH
  end

  def fix_word_count(count : Float64, max = 100_000_000)
    count = count < max ? count : (count / 10000)
    count.round.to_i
  end

  KNOWNS = {"yunqi", "chuangshi", "huayu", "yuedu", "shenqi"}

  def extract_pub_name(pub_link : String)
    return "" if pub_link.empty? || !(host = URI.parse(pub_link).host)
    host = host.split(".")
    KNOWNS.includes?(host.first) ? host.first : host[-2]
  end

  ######################

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  class InvalidJSON < Exception; end

  alias ParserData = NamedTuple(bookInfo: Parser, bookSource: Array(Source))

  struct Parser
    def self.parse_file(file : String) : self
      json = File.read(file)
      raise InvalidJSON.new(file) unless json.starts_with?("{\"success")
      parse_json(json)
    end

    def self.parse_json(json : String) : self
      json = NamedTuple(data: ParserData).from_json(json)
      info = json[:data][:bookInfo]
      info.source = json[:data][:bookSource]
      info
    end

    #################

    include JSON::Serializable

    getter _id : Int32
    getter title = ""
    getter author = ""

    getter introduction = ""

    @[JSON::Field(key: "classInfo")]
    getter class_info : NamedTuple(classId: Int32, className: String)?

    getter tags = [] of String
    getter cover = ""

    @[JSON::Field(key: "updateAt")]
    getter update_str : String = "2020-01-01T07:00:00.000Z"

    @[JSON::Field(key: "scorerCount")]
    getter scorer_count : Int32

    getter score = 0_f32

    @[JSON::Field(key: "countWord")]
    getter count_word = 0_f64

    @[JSON::Field(key: "commentCount")]
    getter comment_count = 0_i32

    getter status = 0
    getter shielded = false
    # getter recom_ignore = false

    property source = [] of Source

    @[JSON::Field(key: "addListCount")]
    getter list_count = 0_i32

    @[JSON::Field(key: "addListTotal")]
    getter list_total = 0_i32
  end
end
