require "json"
require "colorize"
require "file_utils"

require "./chap_item"

# require "../utils/text_utils"

class BookMeta
  include JSON::Serializable

  property uuid = ""

  property intro_zh = ""
  property intro_vi = ""

  property cover_links = [] of String
  property yousuu_link = ""
  property origin_link = ""

  property status = 0_i32
  property mftime = 0_i64

  # seed types: 0 => remote, 1 => manual, 2 => locked

  property seed_lists = [] of String
  property seed_types = {} of String => Int32
  property seed_sbids = {} of String => String

  property latest_times = {} of String => Int64
  property latest_chaps = {} of String => ChapItem

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
    @latest_chaps.each_value { |chap| chap.mark_saved! }
  end

  def intro_zh=(intro : String)
    return if intro == @intro_zh
    @changed = true
    @intro_zh = intro
  end

  def yousuu_link=(yousuu_link : String) : Void
    return if @yousuu_link == yousuu_link
    changed = true
    @yousuu_link = yousuu_link
  end

  def origin_link=(origin_link : String) : Void
    return if @origin_link == origin_link
    changed = true
    @origin_link = origin_link
  end

  def intro_vi=(intro : String)
    return if intro == @intro_vi
    @changed = true
    @intro_vi = intro
  end

  def status=(status : Int32) : Void
    return if status <= @status
    @changed = true
    @status = status
  end

  def mftime=(mftime : Int64) : Void
    return if @mftime >= mftime
    changed = true
    @mftime = mftime
  end

  def add_cover(cover : String)
    return if cover.empty? || @cover_links.includes?(cover)
    @changed = true
    @cover_links << cover
  end

  def add_seed(seed : String, sbid : String, type : Int32 = 0) : Void
    if @seed_lists.includes?(seed)
      return if @seed_sbids[seed] == sbid && @seed_types[seed] == type
    else
      @seed_lists << seed
    end

    @changed = true
    @seed_sbids[seed] = sbid
    @seed_types[seed] = type
    # rescue err
    # puts err
    # puts self
  end

  def set_type(seed : String, type : Int32 = 0) : Void
    return if @seed_types[seed]?.try(&.== type)
    @changed = true
    @seed_types[type] = type
  end

  def set_latest(seed : String, scid : String, title : String, mftime = 0_i64) : Void
    set_latest(seed, ChapItem.new(scid, title), mftime)
  end

  def set_latest(seed : String, chap : ChapItem, mftime = 0_i64)
    if old_chap = @latest_chaps[seed]?
      return if old_chap.scid == chap.scid

      mftime = @mftime if mftime < @mftime
      if mftime <= @latest_times.fetch(seed, 0)
        mftime = Time.utc.to_unix_ms
      end
    end

    @changed = true
    @latest_times[seed] = mftime
    @latest_chaps[seed] = chap
  end

  def to_s(io : IO)
    to_json(io)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def save!(file : String = BookMeta.path_for(@uuid))
    mark_saved!

    File.write(file, self)
    puts "- <book_meta> [#{file.colorize(:cyan)}] saved."
  end

  # class methods

  DIR = File.join("var", "appcv", "book_metas")
  FileUtils.mkdir_p(DIR)

  def self.uuid_for(file : String)
    File.basename(file, ".json")
  end

  def self.glob_dir
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.path_for(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def save!(seed : self, file = path_for(seed.uuid)) : Void
    seed.save!(file) if seed.changed?
  end

  def self.exist?(uuid : String)
    File.exists?(path_for(uuid))
  end

  def self.read_file(file : String)
    from_json(File.read(file))
  end

  def self.get(uuid : String, file = path_for(uuid))
    read_file(file) if File.exists?(file)
  end

  def self.get!(uuid : String) : self
    get(uuid) || raise "- <book_meta> [#{uuid}] not found!"
  end

  def self.get_or_create!(uuid : String) : self
    get(uuid) || new(uuid)
  end

  # Load with cache

  CACHE = {} of String => self

  def self.load_all!
    glob_dir.each { |file| load!(uuid_for(file)) }
    puts "- <book_meta> loaded `#{CACHE.size.colorize(:cyan)}` entries."

    CACHE
  end

  def self.load(uuid : String)
    load!(uuid) if File.exists?(path_for(uuid))
  end

  def self.load!(uuid : String)
    CACHE[uuid] ||= get!(uuid)
  end

  def self.load_or_create!(uuid : String)
    CACHE[uuid] ||= get_or_create!(uuid)
  end
end
