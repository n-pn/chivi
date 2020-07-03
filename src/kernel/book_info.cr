require "json"
require "colorize"
require "file_utils"
require "../utils/gen_uuids"

class BookInfo
  # us == url slug

  include JSON::Serializable

  property uuid = ""
  property slug = ""

  property title_zh = ""
  property title_hv = ""
  property title_vi = ""

  property author_zh = ""
  property author_vi = ""
  property author_us = ""

  property genre_zh = ""
  property genre_vi = ""
  property genre_us = ""

  property intro_zh = ""
  property intro_vi = ""

  property tags_zh = [] of String
  property tags_vi = [] of String
  property tags_us = [] of String

  property cover_links = [] of String
  property local_cover = ""

  property shield = 0_i32
  property voters = 0_i32
  property rating = 0_f32
  property weight = 0_i64

  property word_count = 0_i32
  property crit_count = 0_i32

  property yousuu_link = ""
  property origin_link = ""

  @[JSON::Field(ignore: true)]
  @changed = false

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    if @uuid.empty?
      fix_uuid!
    else
      @changed = true
    end
  end

  def changed?
    @changed
  end

  def mark_saved!
    @changed = false
  end

  def fix_uuid!(force = true) : Void
    return unless force || @uuid.empty?
    self.uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  def set_uuid!(uuid : String, force = false) : Void
    return if uuid.empty?
    return unless force || @uuid.empty?
    self.uuid = uuid
  end

  def uuid=(uuid : String)
    return if @uuid == uuid
    @changed = true
    @uuid = uuid
  end

  def set_title!(title : String, force = false)
    return unless @title_zh.empty? || force

    self.title_zh = title
    self.title_hv = ""
    self.title_vi = ""
  end

  def title_zh=(title : String)
    return if @title_zh == title
    @changed = true
    @title_zh = title
  end

  def title_hv=(title : String)
    return if @title_hv == title
    @changed = true
    @title_hv = title
  end

  def title_vi=(title : String)
    return if @title_vi == title
    @changed = true
    @title_vi = title
  end

  def vi_title
    @title_vi.empty? ? @title_hv : @title_vi
  end

  def set_author!(author : String, force = false)
    return unless @author_zh.empty? || force

    self.author_zh = author
    self.author_vi = ""
    self.author_us = ""
  end

  def author_zh=(author : String)
    return if @author_zh == author
    @changed = true
    @author_zh = author
  end

  def author_vi=(author : String)
    return if @author_vi == author
    @changed = true
    @author_vi = author
  end

  def author_us=(author : String)
    return if @author_us == author
    @changed = true
    @author_us = author
  end

  def author_zh=(author : String)
    return if @author_zh == author
    @changed = true
    @author_zh = author
  end

  def set_genre!(genre : String, force = false)
    return unless @genre_zh.empty? || force

    self.genre_zh = genre
    self.genre_vi = ""
    self.genre_us = ""
  end

  def genre_zh=(genre : String)
    return if genre == @genre_zh
    @changed = true
    @genre_zh = genre
  end

  def genre_vi=(genre : String)
    return if genre == @genre_vi
    @changed = true
    @genre_vi = genre
  end

  def genre_us=(genre : String)
    return if genre == @genre_us
    @changed = true
    @genre_us = genre
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

  def voters=(voters : Int32)
    return if @voters == voters
    @changed = true
    @voters = voters
  end

  def rating=(rating : Float32)
    return if @rating == rating
    @changed = true
    @rating = rating
  end

  def scored
    (@rating * 10).to_i64
  end

  def fix_weight!
    @weight = scored * @voters
  end

  def to_s(io : IO)
    to_json(io)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def save!(file : String = BookInfo.path_for(@uuid)) : Void
    @changed = false
    File.write(file, self)
    puts "- <book_info> [#{file.colorize(:cyan)}] saved."
  end

  # class methods

  DIR = File.join("var", "appcv", "book_infos")
  FileUtils.mkdir_p(DIR)

  def self.path_for(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.save!(info : BookInfo, file = path_for(info.uuid))
    info.save!(file) if info.changed?
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
    BookInfo.from_json(File.read(file))
  end

  def self.get!(uuid : String)
    get(uuid) || raise "- <book_file> #{uuid} not found!"
  end

  def self.get(uuid : String)
    file = path_for(uuid)
    from_file(file) if File.exists?(file)
  end

  def self.find(title : String, author : String)
    get(Utils.gen_uuid(title, author))
  end

  def self.find!(title : String, author : String)
    find(uuid) || raise "- <book_file> #{uuid} not found!"
  end

  def self.find_or_create!(title : String, author : String, uuid : String? = nil)
    uuid ||= Utils.gen_uuid(title, author)
    get(uuid) || new(title, author, uuid)
  end

  # Load with cache

  CACHE = {} of String => BookInfo

  def self.load_all!
    glob_dir.each do |file|
      CACHE[uuid_for(file)] ||= BookInfo.from_file(file)
    end

    CACHE
  end

  def self.load(uuid : String)
    CACHE[uuid] ||= get(uuid)
  end

  def self.load!(uuid : String)
    CACHE[uuid] ||= get!(uuid)
  end

  def self.load_or_create!(title : String, author : String, uuid : String? = nil)
    uuid ||= Utils.gen_uuid(title, author)
    CACHE[uuid] ||= find_or_create!(title, author, uuid)
  end
end
