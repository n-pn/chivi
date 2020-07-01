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

  def fix_uuid! : Void
    self.uuid = Utils.gen_uuid(@title_zh, @author_zh)
  end

  def uuid=(uuid : String)
    return if @uuid == uuid
    @changed = true
    @uuid = uuid
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

  def mark_saved!
    @data.each_value { |data| data.mark_saved! }
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    mark_saved!

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

  def save_all!(only_changed : Bool = true) : Void
    CACHE.each_value do |bulk|
      bulk.save! if bulk.changed? || !only_changed
    end
  end

  def save!(info : Data) : Void
    bulk = load_bulk!(uuid)
    bulk.set(info)
    bulk.save!
  end
end
