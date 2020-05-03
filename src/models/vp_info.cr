require "json"
require "colorize"

require "../utils/hash_id"

class VpInfo
  include JSON::Serializable

  property uuid = ""
  property slug = ""

  property title_zh = ""
  property title_vi = ""
  property title_hv = ""

  property author_zh = ""
  property author_vi = ""
  property author_sl = ""

  property intro_zh = ""
  property intro_vi = ""

  property genre_zh = ""
  property genre_vi = ""
  property genre_sl = ""

  property tags_zh = [] of String
  property tags_vi = [] of String

  property covers = [] of String

  property votes = 0_i32
  property score = 0_f64
  property tally = 0_f64

  property status = 0_i32
  property shield = 0_i32
  property uptime = 0_i64

  property yousuu = ""
  property origin = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property cr_anchors = {} of String => String
  property cr_uptimes = {} of String => String

  property cr_site_df = ""
  property cr_bsid_df = ""

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    @uuid = gen_uuid(@title_zh, @author_zh) if @uuid.empty?
  end

  def gen_uuid(title = @zh_title, author = @zh_author)
    Utils.hash_id("#{title}--#{author}")
  end

  def intro_zh=(intro : String)
    @intro_zh = intro.tr("　 ", " ")
      .gsub("&amp;", "&")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("&nbsp;", " ")
      .gsub(/<br\s*\/?>/, "\n")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
  end

  def uptime=(uptime : Int64)
    @uptime = uptime if uptime > @uptime
  end

  def status=(status : Int32)
    @status = status if status > @status
  end

  DIR = File.join("data", "zh_infos")

  def self.file_path(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.from_file(file : String)
    from_json(File.read(file))
  end

  def self.load_json(uuid : String)
    from_file(file_path(uuid))
  end

  def self.save_json(info : VpInfo)
    File.write(file_path(info.uuid), info.to_pretty_json)
  end

  @@infos = {} of String => VpInfo

  def self.load_all(reset : Bool = false)
    count = 0

    files = Dir.glob(File.join(DIR, "*.json"))
    files.each do |file|
      uuid = File.basename(file, ".json")
      next if !reset && @@infos.has_key?(uuid)

      count += 1
      @@infos[uuid] = from_file(file)
    end

    puts "- loaded #{count.colorize(:blue)} entries"
    @@infos
  end

  def self.load_cache(uuid : String)
    @@infos[uuid] ||= load_json(uuid)
  end
end
