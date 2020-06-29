require "json"
require "colorize"
require "../utils/gen_uuids"

class BookInfo
  include JSON::Serializable

  property uuid = ""
  property slug = ""

  property zh_title = ""
  property vi_title = ""
  property hv_title = ""

  property zh_author = ""
  property vi_author = ""

  property zh_genre = ""
  property vi_genre = ""

  property zh_tags = [] of String
  property vi_tags = [] of String

  property voters = 0_i32
  property rating = 0_f64
  property weight = 0_f64

  def initialize
  end

  def initialize(@zh_title : String, @zh_author : String, @uuid = "")
    fix_uuid! if @uuid.empty?
  end

  def fix_uuid!
    @uuid = Utils.gen_uuid(@zh_title, @zh_author)
  end

  def set_genre(genre : String)
    genre = fix_label(genre)
    return if genre.empty? || genre == @zh_genre

    @zh_genre = genre
    @vi_genre = ""
  end

  def add_tags(tags : Array(String))
    return if tags.empty?
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty?

    tag = fix_label(tag)
    return if @zh_tags.includes?(tag)

    @zh_tags << tag
    @vi_tags << ""
  end

  private def fix_label(label : String)
    return label if label.empty? || label == "轻小说"
    label.sub("小说", "")
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
