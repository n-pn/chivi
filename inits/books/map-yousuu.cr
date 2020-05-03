require "json"
require "colorize"
require "file_utils"

require "../../src/models/vp_info"

struct Source
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

struct Serial
  include JSON::Serializable

  property _id : Int32
  property uuid = ""

  property title = ""
  property author = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?
  property genre = ""

  property tags = [] of String
  property cover = ""

  property status = 0
  property shielded = false

  property countWord = 0_f64

  property commentCount = 0

  property scorerCount = 0
  property score = 0_f64

  property updateAt = Time.utc

  property sources = [] of Source

  FIX_DIR     = "inits/books/yousuu"
  FIX_MAP     = Hash(String, String)
  FIX_TITLES  = FIX_MAP.from_json(File.read("#{FIX_DIR}/fix-titles.json"))
  FIX_AUTHORS = FIX_MAP.from_json(File.read("#{FIX_DIR}/fix-authors.json"))

  def fix_title!
    @title = @title.sub(/\(.+\)$/, "").strip
    @title = FIX_TITLES.fetch(@title, @title)
  end

  def fix_author!
    @author = @author.sub(/\(.+\)|.QD$/, "").strip
    @author = FIX_AUTHORS.fetch(@author, @author)
  end

  def fix_genre!
    if genre = @category
      @genre = genre[:className]
      @genre.sub("小说", "") unless @genre == "轻小说"
    end
  end

  def fix_tags!
    @tags = @tags.map(&.split("-")).flatten.uniq.reject do |tag|
      tag == @genre || tag == @title || tag == @author
    end
  end

  def fix_cover!
    if @cover.starts_with?("http")
      @cover =
        @cover
          .sub("http://image.qidian.com/books", "https://qidian.qpic.cn/qdbimg")
          .sub("/300", "/300.jpg")
    else
      @cover = ""
    end
  end

  def uuid
    return @uuid unless @uuid.empty?
    @uuid = Utils.hash_id("#{title}--#{author}")
  end
end

MAP_DIR = File.join("data", "sitemaps")
FileUtils.mkdir_p(MAP_DIR)

alias Mapping = NamedTuple(uuid: String, title: String, author: String)
MAPFILE = File.join(MAP_DIR, "yousuu.json")

if File.exists?(MAPFILE)
  sitemap = Hash(String, Mapping).from_json File.read(MAPFILE)
  updated = File.info(MAPFILE).modification_time
else
  sitemap = {} of String => Mapping
  updated = Time.local(2000, 1, 1)
end

puts "- mapped: #{sitemap.size.colorize(:blue)} entries"

alias Data = NamedTuple(bookInfo: Serial, bookSource: Array(Source))

files = Dir.glob("data/inits/txt-inp/yousuu/infos/*.json").reject do |file|
  bsid = File.basename(file, ".json")
  sitemap.has_key?(bsid) && updated > File.info(file).modification_time
end

# files = files.sort_by do |file|
#   File.basename(file, ".json").to_i
# end

serials = {} of String => Serial
files.each do |file|
  text = File.read(file)
  next unless text.includes?("{\"success\":true")

  input = NamedTuple(data: Data).from_json(text)
  serial = input[:data][:bookInfo]

  serial.fix_title!
  serial.fix_author!

  sitemap[serial._id.to_s] = {
    uuid:   serial.uuid,
    title:  serial.title,
    author: serial.author,
  }

  next if serial.score == 0 || serial.title.empty? || serial.author.empty?

  if old_serial = serials[serial.uuid]?
    next if old_serial.updateAt >= serial.updateAt
  end

  serial.fix_cover!
  serial.fix_genre!
  serial.fix_tags!

  serial.sources = input[:data][:bookSource]

  serials[serial.uuid] = serial
rescue err
  File.delete(file)
  puts "#{file} err: #{err}".colorize(:red)
end

File.write(MAPFILE, sitemap.to_pretty_json)

puts "- input: #{files.size.colorize(:blue)} entries, parse: #{serials.size.colorize(:blue)}"

exit 0 if serials.size == 0

FileUtils.mkdir_p(VpInfo::DIR)

infos = VpInfo.load_all
fresh = 0

serials.each do |uuid, serial|
  unless info = infos[uuid]?
    fresh += 1
    info = VpInfo.new(serial.title, serial.author)
  end

  info.intro_zh = serial.intro if info.intro_zh.empty?
  info.genre_zh = serial.genre if info.genre_zh.empty?
  info.tags_zh.concat(serial.tags).uniq!
  info.covers.push(serial.cover).uniq! unless serial.cover.empty?

  info.votes = serial.scorerCount
  info.score = (serial.score * 10).round / 10
  info.tally = (info.votes * info.score * 2).round / 2

  info.status = serial.status
  info.shield = serial.shielded ? 2 : 0
  info.uptime = serial.updateAt.to_unix_ms

  info.yousuu = serial._id.to_s
  if source = serial.sources.first?
    info.origin = source.link
  end

  info.word_count = serial.countWord.round.to_i
  info.crit_count = serial.commentCount

  VpInfo.save_json(info)
end

puts "- existed: #{infos.size.colorize(:blue)}, fresh: #{fresh.colorize(:blue)}"
