require "json"
require "colorize"
require "file_utils"
require "../utils/text_utils"

require "./chap_item"

class BookMisc::Data
  # contain book optional infomation

  include JSON::Serializable

  property uuid = ""

  property intro_zh = ""
  property intro_vi = ""

  property tags_zh = [] of String
  property tags_vi = [] of String
  property tags_us = [] of String

  property cover_links = [] of String
  property local_cover = ""

  property status = 0_i32
  property shield = 0_i32
  property mftime = 0_i64

  property yousuu_link = ""
  property origin_link = ""

  # seed types: 0 => remote, 1 => manual, 2 => locked
  property seed_types = {} of String => Int32
  property seed_sbids = {} of String => String
  property seed_chaps = {} of String => ChapItem

  property word_count = 0_i32
  property crit_count = 0_i32

  @[JSON::Field(ignore: true)]
  property changed = false

  def initialize(@uuid : String = "")
    @changed = true
  end

  def changed?
    @changed
  end

  def mark_saved!
    @changed = false
    @seed_chaps.each_value { |chap| chap.mark_saved! }
  end

  def intro_zh=(intro : String)
    return if intro == @intro_zh
    @changed = true
    @intro_zh = intro
  end

  def intro_vi=(intro : String)
    return if intro == @intro_vi
    @changed = true
    @intro_vi = intro
  end

  def add_tags(tags : Array(String))
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty? || @tags_zh.includes?(tag)
    @changed = true

    @tags_zh << tag
    @tags_vi << ""
    @tags_us << ""
  end

  def add_cover(cover : String)
    return if cover.empty? || @cover_links.includes?(cover)
    @changed = true
    @cover_links << cover
  end

  def status=(status : Int32) : Void
    return if status <= @status
    @changed = true
    @status = status
  end

  def set_seed_sbid(seed : String, sbid : String) : Void
    return if @seed_sbids[seed]?.try(&.== sbid)
    @changed = true
    @seed_sbids[seed] = sbid
  end

  def set_seed_type(seed : String, type : Int32 = 0) : Void
    return if @seed_types[seed]?.try(&.== type)
    @changed = true
    @seed_types[seed] = type
  end

  def set_seed_chap(seed : String, scid : String, title : String, mftime = 0_i64) : Void
    set_seed_chap(seed, ChapItem.new(scid, title, mftime: mftime))
  end

  def set_seed_chap(seed : String, chap : ChapItem)
    if old_chap = @seed_chaps[seed]?
      return if old_chap.scid == chap.scid

      if old_chap.mftime == chap.mftime
        chap.mftime = Time.utc.to_unix_ms
      end
    end

    @changed = true
    @seed_chaps[seed] = chap
  end

  def mftime=(mftime : Int64) : Void
    return if @mftime >= mftime
    changed = true
    @mftime = mftime
  end

  def to_s(io : IO)
    to_json(io)
  end
end

class BookMiscNotFound < Exception
  def initialize(uuid : String)
    super("Book misc uuid [#{uuid}] does not exit")
  end
end

module BookMisc
  extend self

  DIR = File.join("var", "appcv", "book_miscs")
  FileUtils.mkdir_p(DIR)

  def path(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def uuid_of(file : String)
    File.basename(file, ".json")
  end

  def glob_dir
    Dir.glob(File.join(DIR, "*.json"))
  end

  def exist?(uuid : String)
    File.exists?(path(uuid))
  end

  CACHE = {} of String => Data

  def load_all! : Void
    files = glob_dir
    files.each { |file| load!(uuid_of(file)) }
    puts "- <book_misc> loaded `#{files.size.colorize(:cyan)}` entries."
  end

  def all_uuids : Array(String)
    glob_dir.map { |file| uuid_of(file) }
  end

  def each(load_all : Bool = false)
    load_all! if load_all
    CACHE.each_value { |misc| yield misc }
  end

  def get!(uuid : String) : Data
    get(uuid) || raise BookMiscNotFound.new(uuid)
  end

  def get(uuid : String)
    CACHE[uuid] ||= begin
      file = path(uuid)
      return unless File.exists?(file)
      load!(file)
    end
  end

  def get_or_create!(uuid : String) : Data
    unless misc = get(uuid)
      misc = Data.new(uuid)
      CACHE[uuid] = misc
    end

    misc
  end

  def load!(file : String)
    Data.from_json(File.read(file))
  end

  def save!(misc : Data, file = path(misc.uuid)) : Void
    File.write(file, misc)
    misc.mark_saved!
    puts "- <book_misc> [#{file.colorize(:cyan)}] saved."
  end
end
