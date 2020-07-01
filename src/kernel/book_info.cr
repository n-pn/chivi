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

  @[JSON::Field(ignore: true)]
  @changed = false

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @uuid = "")
    @changed = true
    gen_uuid! if @uuid.empty?
  end

  def changed?
    @changed
  end

  def gen_uuid!
    @uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  def set_title(title : String) : Void
    return if title.empty? || @title_zh == title

    @title_zh = title
    @title_hv = ""
    @title_vi = ""
    @changed = true
  end

  def set_author(author : String) : Void
    return if author.empty? || @author_zh == author

    @author_zh = author
    @author_vi = ""
    @author_us = ""
    @changed = true
  end

  def set_genre(genre : String) : Void
    return if genre.empty? || genre == @genre_zh
    genre = fix_genre(genre)

    if @genre_zh.empty?
      @genre_zh = genre
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
    case tag
    when .empty?, @title_zh, @author_zh
      return
    else
      return if @tags_zh.includes?(tag)

      @tags_zh << tag
      @tags_vi << ""
      @tags_us << ""

      @changed = true
    end
  end

  def set_voters(voters : Int32)
    return if @voters == voters
    @voters = voters
    @changed = true
  end

  def set_rating(rating : Float32)
    return if @rating == rating
    @rating = rating
    @changed = true
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
end

struct BookInfo::Bulk
  getter file : String
  getter data = {} of String => Data

  def initialize(@file, preload : Bool = true)
    load! if preload && exist?
  end

  def exist?
    File.exists?(@file)
  end

  def get(uuid : String)
    @data[uuid]?
  end

  def set(data : Data)
    @data[data.uuid] = data
  end

  def load!(file : String = @file) : Void
    @data.merge! Hash(String, Data).from_json(File.read(file))
  end

  def changed? : Bool
    @data.values.reduce(false) { |acc, i| acc ||= i.changed? }
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <book_info> [#{file.colorize(:cyan)}] saved."
  end

  def to_s(io : IO)
    @data.to_json(io)
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

class BookNotFound < Exception
  def initialize(uuid : String)
    super("Book with uuid [#{uuid}] does not exist")
  end
end

module BookInfo
  extend self

  DIR = File.join("var", "appcv", "book_infos")
  FileUtils.mkdir_p(DIR)

  def path(drop : String)
    File.join(DIR, "#{drop}.json")
  end

  def glob_dir
    Dir.glob(File.join(DIR, "*.json"))
  end

  CACHE = {} of String => Bulk

  def load_all! : Void
    glob_dir.each do |file|
      uuid = File.basename(file, ".json")
      load!(uuid, file)
    end
  end

  def save_all!(only_changed : Bool = true) : Void
    CACHE.each_value do |bulk|
      bulk.save! if bulk.changed? || !only_changed
    end
  end

  def load_bulk!(uuid : String)
    bulk_id = get_bulk_id(uuid)
    CACHE[bulk_id] ||= Bulk.new(path(bulk_id), preload: true)
  end

  def get_bulk_id(uuid : String)
    uuid[0, 2]
  end

  def each(load_all : Bool = false)
    load_all! if load_all

    CACHE.each_value do |bulk|
      bulk.each_value do |data|
        yield data
      end
    end
  end

  def get(uuid : String) : Data?
    load_bulk!(uuid).get(uuid)
  end

  def get!(uuid : String) : Data
    get(uuid) || raise BookNotFound.new(uuid)
  end

  def find(title : String, author : String)
    get(Utils.gen_uuid(title, author))
  end

  def find!(title : String, author : String)
    find(uuid) || raise BookNotFound.new(uuid)
  end

  def find_or_create!(title : String, author : String)
    uuid = Utils.gen_uuid(title, author)
    bulk = load_bulk!(uuid)

    unless data = bulk.get(uuid)
      data = Data.new(title, author, uuid)
      bulk.set(data)
    end

    data
  end
end
