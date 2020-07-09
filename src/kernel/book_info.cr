require "colorize"
require "file_utils"

require "./base_model"
require "./chap_item"

require "../_utils/gen_uuids"

class BookSeed
  include BaseModel

  # seed types: 0 => remote, 1 => manual, 2 => locked
  property type = 0

  property name = ""
  property sbid = ""

  property mftime = 0_i64
  property latest = ChapItem.new

  def initialize(@name, @type = 0)
  end

  def update_changes!
    @changes += @latest.reset_changes!
  end
end

class BookInfo
  include BaseModel

  property uuid = ""
  property slug = ""

  property title_zh = ""
  property title_vi = ""

  property author_zh = ""
  property author_vi = ""

  property intro_zh = ""
  property intro_vi = ""

  property genre_zh = ""
  property genre_vi = ""

  property tags_zh = [] of String
  property tags_vi = [] of String

  property voters = 0_i32
  property rating = 0_f32
  property weight = 0_i64

  property shield = 0_i32
  property status = 0_i32
  property mftime = 0_i64

  property cover_urls = [] of String
  property main_cover = ""

  property yousuu_url = ""
  property origin_url = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property view_count = 0_i32
  property read_count = 0_i32

  property seeds = {} of String => BookSeed

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    if @uuid.empty?
      fix_uuid
    else
      @changes = 1
    end
  end

  def fix_uuid : Void
    self.uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  {% for field in {:title, :author, :genre} %}
    def set_{{field.id}}(value : String, force = false)
      return if @{{field.id}}_zh == value
      return unless @{{field.id}}_zh.empty? || force

      self.{{field.id}}_zh = value
      self.{{field.id}}_vi = ""
    end
  {% end %}

  def add_tags(tags : Array(String))
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty? || @tags_zh.includes?(tag)
    @changes += 1

    @tags_zh << tag
    @tags_vi << ""
  end

  def add_cover(cover : String)
    return if cover.empty? || @cover_urls.includes?(cover)
    @changes += 1
    @cover_urls << cover
  end

  def scored
    (@rating * 10).to_i64
  end

  def fix_weight
    @weight = scored * @voters
  end

  def status=(status : Int32)
    return if status <= @status
    @changes += 1
    @status = status
  end

  def mftime=(mftime : Int64)
    return if mftime <= @mftime
    @changes += 1
    @mftime = mftime
  end

  def add_seed(name : String, type = 0)
    if seed = @seeds[name]?
      seed.type = type
      @changes += seed.reset_changes!
    else
      seed = seeds[name] = BookSeed.new(name, type)
      @changes += 1
    end

    seed
  end

  def update_seed(name : String, sbid : String, scid : String, mftime : Int64, &block : BookSeed -> Void)
    seed = @seeds[name] ||= BookSeed.new(name, 0)

    if seed.sbid != sbid
      return seed if seed.mftime > mftime
      seed.sbid = sbid
    end

    mftime = @mftime if mftime < @mftime
    mftime = seed.mftime if mftime < seed.mftime

    if seed.latest.scid != scid
      seed.latest.scid = scid
      mftime = Time.utc.to_unix_ms if mftime == seed.mftime

      yield(seed) if block
    end

    seed.mftime = mftime
    seed.update_changes! # transfer changes count from latest chap to book seed

    @changes += seed.reset_changes! # transfer changes count from seed to info
    seed
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    to_json(io)
  end

  def save!(file : String = BookInfo.path_for(@uuid)) : Void
    File.write(file, self)
    puts "- <book_info> [#{file.colorize(:blue)}] saved \
            (#{@changes.colorize(:blue)} changes)."
    @changes = 0
  end

  # class methods

  DIR = File.join("var", "book_infos")
  FileUtils.mkdir_p(DIR)

  def self.path_for(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.glob_dir
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.uuid_for(file : String)
    File.basename(file, ".json")
  end

  def self.exists?(uuid : String)
    File.exists?(path_for(uuid))
  end

  def self.from_file(file : String)
    from_json(File.read(file))
  end

  CACHE = {} of String => BookInfo

  def self.load!(uuid : String, cache = true)
    load(uuid, cache) || raise "- <book_info> [#{uuid}] not found!"
  end

  def self.load(uuid : String, cache = true)
    unless info = CACHE[uuid]?
      file = path_for(uuid)
      return unless File.exists?(file)

      info = from_file(file)
      CACHE[uuid] = info if cache
    end

    info
  end

  def self.find!(title : String, author : String, cache = true)
    load!(Utils.gen_uuid(title, author), cache)
  end

  def self.find(title : String, author : String, cache = true)
    load(Utils.gen_uuid(title, author), cache)
  end

  def self.find_or_create(title : String, author : String, uuid = Utils.gen_uuid(title, author), cache = true)
    unless info = load(uuid, cache)
      info = new(title, author, uuid)
      CACHE[uuid] = info if cache
    end

    info
  end

  # Load with cache

  def self.load_all!(cache = true)
    all = glob_dir.map do |file|
      load!(uuid_for(file), cache)
    end

    puts "- <book_info> loaded all (#{all.size.colorize(:green)} entries)."
    all
  end
end
