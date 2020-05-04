require "json"
require "colorize"
require "file_utils"

require "../../src/models/vp_info"
require "./mapping_util"

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
      @genre = fix_label(genre[:className])
    end
  end

  def fix_tags!
    @tags = @tags.map(&.split("-")).flatten.map { |tag| fix_label(tag) }.uniq
  end

  def fix_label(label)
    return label if label == "轻小说"
    label.sub("小说", "")
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

alias Data = NamedTuple(bookInfo: Serial, bookSource: Array(Source))

Mapping.mkdir!
sitemap, unmapped = Mapping.load!("yousuu")

inputs = {} of String => Serial

unmapped.each do |file|
  text = File.read(file)

  unless text.includes?("{\"success\":true")
    sitemap[File.basename(file, ".json")] = Mapping.new("-", "-", "-", Mapping.maptime(file))
    next
  end

  input = NamedTuple(data: Data).from_json(text)
  serial = input[:data][:bookInfo]

  serial.fix_title!
  serial.fix_author!

  sitemap[serial._id.to_s] = Mapping.new(serial.uuid, serial.title, serial.author, Mapping.maptime(file))

  next if serial.score == 0 || serial.title.empty? || serial.author.empty?

  if old_serial = inputs[serial.uuid]?
    next if old_serial.updateAt >= serial.updateAt
  end

  serial.fix_cover!
  serial.fix_genre!
  serial.fix_tags!

  serial.sources = input[:data][:bookSource]

  inputs[serial.uuid] = serial
rescue err
  File.delete(file)
  puts "#{file} err: #{err}".colorize(:red)
end

Mapping.save!("yousuu", sitemap)

puts "- new entries: #{inputs.size.colorize(:blue)}"
exit 0 if inputs.size == 0

FileUtils.mkdir_p(VpInfo::DIR)

infos = VpInfo.load_all
fresh = 0

inputs.each do |uuid, serial|
  unless info = infos[uuid]?
    fresh += 1
    info = VpInfo.new(serial.title, serial.author)
  end

  info.set_intro_zh(serial.intro, force: true)
  info.set_genre_zh(serial.genre, force: true)
  info.set_tags_zh(serial.tags)
  info.add_cover(serial.cover)

  info.votes = serial.scorerCount
  info.score = (serial.score * 10).round / 10
  info.reset_tally

  info.shield = serial.shielded ? 2 : 0
  info.set_status(serial.status)
  info.set_update(serial.updateAt.to_unix_ms)

  info.yousuu = serial._id.to_s
  if source = serial.sources.first?
    info.origin = source.link
  end

  info.word_count = serial.countWord.round.to_i
  info.crit_count = serial.commentCount

  VpInfo.save_json(info)
end

puts "- existed: #{infos.size.colorize(:blue)}, fresh: #{fresh.colorize(:blue)}"
