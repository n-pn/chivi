require "json"
require "colorize"
require "file_utils"
require "../utils/gen_uuids"

class BookInfo::Data
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
  property rating = 0_f32
  property weight = 0_i64

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    gen_uuid! if @uuid.empty?
  end

  def gen_uuid!
    @uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  def scored
    (@rating * 10).to_i64
  end

  def fix_weight!
    @weight = scored * @voters
  end

  def title_zh=(@title_zh : String)
    @title_hv = ""
    @title_vi = ""
  end

  def author_zh=(@author_zh : String)
    @author_vi = ""
    @author_us = ""
  end

  def genre_zh=(@genre_zh : String)
    @genre_vi = ""
    @genre_us = ""
  end

  def add_tags(tags : Array(String))
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String, uniq : Bool = false)
    return if !uniq && @tags_zh.includes?(tag)

    @tags_zh << tag
    @tags_vi << ""
    @tags_us << ""
  end

  def to_s(io : IO)
    to_json(io)
  end
end

struct BookInfo::File
  getter file : String
  getter data : Data

  delegate to_s, to: @data
  delegate gen_uuid!, to: @data
  delegate fix_weight!, to: @data

  def initialize(@file, preload : Bool = true)
    if preload && exist?
      @data = Data.from_json(::File.read(file))
      @changed = false
    else
      @data = Data.new
      @changed = true
    end
  end

  def save! : Void
    ::File.write(file, self)
    puts "- <book_info> [#{file.colorize(:cyan)}] saved."
  end

  def exist?
    ::File.exists?(@file)
  end

  def changed?
    @changed
  end

  def set_uuid(uuid : String) : Void
    @data.uuid = uuid
  end

  def set_title(title : String) : Void
    return if title.empty? || @data.title_zh == title
    @data.title_zh = title
    @changed = true
  end

  def set_author(author : String) : Void
    return if author.empty? || @data.author_zh == author
    @data.author_zh = author
    @changed = true
  end

  def add_genre(genre : String) : Void
    return if genre.empty? || genre == @data.genre_zh

    genre = fix_genre(genre)

    if @data.genre_zh.empty?
      @data.genre_zh = genre
      @changed = true
    else
      add_tag(genre)
    end
  end

  private def fix_genre(genre : String)
    return genre if genre.empty? || genre == "轻小说"
    genre.sub(/小说$/, "")
  end

  def add_tags(tags : Array(String))
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty? || @data.tags_zh.includes?(tag)
    return if tag == @data.title_zh || tag == @data.author_zh

    @data.add_tag(tag, uniq: true)
    @changed = true
  end

  def set_voters(voters : Int32)
    return if @data.voters == voters
    @data.voters = voters
    @changed = true
  end

  def set_rating(rating : Float32)
    return if @data.rating == rating
    @data.rating = rating
    @changed = true
  end
end

module BookInfo
  extend self

  DIR = ::File.join("var", "appcv", "book_infos")
  FileUtils.mkdir_p(DIR)

  def path(uuid : String)
    ::File.join(DIR, "#{uuid}.json")
  end

  def files
    Dir.glob(File.join(DIR, "*.json"))
  end

  def uuids
    files.map { |file| ::File.basename(file, ".json") }
  end

  CACHE = {} of String => File

  def load_all!
    files.each do |file|
      uuid = File.basename(file, ".json")
      load!(uuid, file)
    end

    puts "- <book_info> loaded `#{CACHE.size.colorize(:cyan)}` entries."

    CACHE
  end

  def load!(uuid : String) : File
    CACHE[uuid] ||= File.new(path(uuid), preload: true)
  end

  def init!(title : String, author : String) : File
    uuid = Utils.gen_uuid(title, author)
    file = load!(uuid)

    unless file.exist?
      file.data.uuid = uuid
      file.data.title_zh = title
      file.data.author_zh = author
    end

    file
  end
end
