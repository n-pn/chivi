require "json"
require "colorize"
require "file_utils"

class BookMisc
  # contain book optional infomation

  include JSON::Serializable

  property uuid = ""

  property intro_zh = ""
  property intro_vi = ""

  property covers = [] of String

  property status = 0_i32
  property shield = 0_i32
  property mftime = 0_i64

  property yousuu_link = ""
  property origin_link = ""
  property prefer_seed = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  def initialize(@uuid : String)
  end

  def set_intro(intro : String)
    return if intro.empty? || intro == @intro_zh

    @intro_zh = intro.tr("　 ", " ")
      .gsub("&amp;", "&")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("&nbsp;", " ")
      .gsub(/<br\s*\/?>/, "\n")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
    @intro_vi = ""
  end

  def add_cover(cover : String)
    return if cover.empty? || @covers.includes?(cover)
    @covers << cover
  end

  def set_status(status : Int32) : Void
    @status = status if status > @status
  end

  MFTIME = Time.utc.to_unix_ms
  DFTIME = Time.utc(2000, 1, 1).to_unix_ms

  def set_mftime(mftime : Int64) : Void
    mftime = DFTIME if mftime > MFTIME
    @mftime = mftime if mftime > @mftime
  end

  def to_s(io : IO)
    to_json(io)
  end

  def save!(file = BookMisc.path(@uuid)) : self
    File.write(file, self)
    # puts "- <book_misc> [#{file.colorize(:cyan)}] saved."

    self
  end

  # class methods

  DIR = File.join("var", "appcv", "book_miscs")
  FileUtils.mkdir_p(DIR)

  def self.path(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.files
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.uuids
    files.map { |file| File.basename(file, ".json") }
  end

  CACHE = {} of String => BookMisc

  def self.load_all!
    uuids.each { |uuid| load!(uuid) }
    puts "- <book_misc> loaded `#{CACHE.size.colorize(:cyan)}` entries."

    CACHE
  end

  def self.load!(uuid : String) : BookMisc
    CACHE[uuid] ||= init!(uuid)
  end

  def self.init!(uuid : String) : BookMisc
    file = path(uuid)

    if File.exists?(file)
      from_json(File.read(file))
    else
      new(uuid)
    end
  end
end
