require "json"
require "colorize"
require "../utils/gen_uuids"

class BookInfo
  # contain book main infomation
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

  property tags_zh = [] of String
  property tags_vi = [] of String
  property tags_us = [] of String

  property voters = 0_i32
  property rating = 0_f64
  property weight = 0_f64

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    fix_uuid! if @uuid.empty?
  end

  def fix_uuid!
    @uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  def add_genre(genre : String)
    genre = fix_label(genre)
    return if genre.empty? || genre == @genre_zh

    if @genre_zh.empty?
      @genre_zh = genre
      @genre_vi = ""
    else
      add_tag(genre)
    end
  end

  def add_tags(tags : Array(String))
    return if tags.empty?
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty?

    tag = fix_label(tag)
    return if tag == @title_zh || tag == @author_zh
    return if @tags_zh.includes?(tag)

    @tags_zh << tag
    @tags_vi << ""
    @tags_us << ""
  end

  private def fix_label(label : String)
    return label if label.empty? || label == "轻小说"
    label.sub(/小说$/, "")
  end

  def fix_weight!
    @weight = (@voters * @rating * 2).round / 2
  end

  def to_s(io : IO)
    to_json(io)
  end

  # class methods

  DIR = File.join("var", "appcv", "book_infos")

  def self.setup!
    FileUtils.mkdir_p(DIR)
  end

  def self.reset!
    FileUtils.rm_rf(DIR)
    setup!
  end

  def self.path(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.files
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.uuids
    files.map { |file| File.basename(file, ".json") }
  end

  CACHE = {} of String => BookInfo

  def self.load_all!
    uuids.each { |uuid| load!(uuid) }
    puts "- <book_info> loaded `#{cache.size.colorize(:cyan)}` entries."

    CACHE
  end

  def self.load!(uuid : String) : BookInfo
    CACHE[uuid] ||= from_json(File.read(path(uuid)))
  end

  def self.load!(title : String, author : String) : BookInfo
    uuid = Utils.gen_uuid(title, author)
    CACHE[uuid] ||= init!(title, author, uuid)
  end

  def self.init!(title : String, author : String, uuid = Utils.gen_uuid(title, author)) : BookInfo
    file = path(uuid)

    if File.exists?(file)
      from_json(File.read(file))
    else
      new(title, author, uuid)
    end
  end

  def self.save!(info : BookInfo, file = path(info.uuid)) : Void
    File.write(file, info)
    # puts "- <book_info> [#{file.colorize(:cyan)}] saved."
  end
end
