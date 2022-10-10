require "uri"

require "./bootstrap"
require "../../src/ysapp/models/*"

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
  getter genres : Array(String) { @tags.flat_map(&.split("-")).unshift(klass).uniq! }

  getter cover = ""
  getter bcover : String { fix_cover(@cover) }

  @[JSON::Field(key: "updateAt")]
  getter update_str : String = "2020-01-01T07:00:00.000Z"
  getter update_int : Int64 { parse_time(update_str).to_unix }

  @[JSON::Field(key: "scorerCount")]
  getter voters : Int32

  getter score = 0_f32
  getter rating : Int32 { score.*(10).round.to_i }

  getter status = 0
  getter shielded = false
  getter shield : Int32 { shielded ? 1 : 0 }
  # getter recom_ignore = false

  @[JSON::Field(key: "countWord")]
  getter words = 0_f64
  getter word_count : Int32 { (words < 100_000_000 ? words : words / 10000).round.to_i }

  @[JSON::Field(key: "commentCount")]
  getter crit_count = 0_i32

  @[JSON::Field(key: "addListCount")]
  getter list_count = 0_i32

  @[JSON::Field(key: "addListTotal")]
  getter list_total = 0_i32

  getter pub_link : String { source[0]?.try(&.link) || "" }
  getter pub_name : String { extract_pub_name(pub_link) }

  property source = [] of Source
  property blists = [] of Yblist

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

  def should_seed?
    self.voters > 9 || self.crit_count > 4 || self.list_total > 1
  end

  AUTHORS = {} of String => Author

  def load_author(zname : String)
    AUTHORS[zname] ||= Author.find({zname: zname}) || begin
      should_seed? ? Author.upsert!(zname) : return
    end
  end

  def seed!(stime = Time.utc.to_unix, force = false) : Nil
    return if btitle.empty? || author.empty?
    btitle_zh, author_zh = BookUtil.fix_names(btitle, author)

    params = {id: _id.to_i64}

    if ysbook = Ysbook.find(params)
      return unless force || ysbook.stime < stime || ysbook.voters < voters
      author = Author.upsert!(author_zh)
    else
      return unless author = load_author(author_zh)
      ysbook = Ysbook.new(params)
    end

    btitle = Btitle.upsert!(btitle_zh)
    ysbook.nvinfo = Nvinfo.upsert!(author, btitle)

    update_ysbook(ysbook, stime)
    ysbook.update_nvinfo
    ysbook.save!

    self.blists.each do |yblist|
      next if YS::Yslist.find({origin_id: yblist._id})
      YS::Yslist.new({
        id:        yblist.id,
        origin_id: yblist._id,
        zname:     yblist.title,
        vname:     MtCore.generic_mtl.translate(yblist.title),
      }).save
    rescue err
      Log.error { err }
    end
  end

  def update_ysbook(ysbook : Ysbook, stime : Int64)
    ysbook.stime = stime

    ysbook.btitle = self.btitle
    ysbook.author = self.author

    ysbook.set_mftime(self.update_int)
    ysbook.set_bcover(self.bcover)
    ysbook.set_bintro(self.bintro)
    ysbook.set_genres(self.genres)
    ysbook.set_status(self.status)
    ysbook.set_shield(self.shield)

    ysbook.voters = self.voters
    ysbook.scores = self.voters &* self.rating

    ysbook.word_count = self.word_count
    ysbook.crit_total = self.crit_count
    ysbook.list_total = self.list_total

    ysbook.pub_name = self.pub_name
    ysbook.pub_link = self.pub_link
  end

  ########################

  struct Source
    include JSON::Serializable

    @[JSON::Field(key: "siteName")]
    property site : String

    @[JSON::Field(key: "bookPage")]
    property link : String
  end

  struct Yblist
    include JSON::Serializable

    getter _id : String
    getter id : Int64 { _id[12..].to_i64(base: 16) }

    getter title : String
  end

  alias List = NamedTuple(booklistId: Yblist)

  struct Rawdata
    include JSON::Serializable

    @[JSON::Field(key: "bookInfo")]
    getter info : YsbookRaw

    @[JSON::Field(key: "bookSource")]
    getter source : Array(Source)

    getter booklist : Array(List)
  end

  def self.parse_file(file : String)
    text = File.read(file)
    return unless text.starts_with?("{\"success")

    json = NamedTuple(data: Rawdata).from_json(text)[:data]
    json.info.tap do |info|
      info.source = json.source
      info.blists = json.booklist.map { |x| x[:booklistId] }
    end
  end
end
