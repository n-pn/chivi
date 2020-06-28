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

  property zh_intro = ""
  property vi_intro = ""

  property covers = [] of String

  property voters = 0_i32
  property rating = 0_f64
  property weight = 0_f64

  property status = 0_i32
  property shield = 0_i32
  property mftime = 0_i64

  property yousuu = ""
  property origin = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property cr_sitemap = {} of String => String
  property cr_site_df = ""

  property last_times = {} of String => Int64
  property last_csids = {} of String => String
  property last_texts = {} of String => String
  property last_slugs = {} of String => String

  def initialize
  end

  def initialize(@zh_title : String, @zh_author : String, @uuid = "")
    reset_uuid! if @uuid.empty?
  end

  def reset_uuid!
    @uuid = Utils.gen_uuid(@zh_title, @zh_author)
  end

  def zh_intro=(intro : String)
    return if intro.empty? || intro == @zh_intro

    @zh_intro = intro.tr("　 ", " ")
      .gsub("&amp;", "&")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("&nbsp;", " ")
      .gsub(/<br\s*\/?>/, "\n")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
    @vi_intro = ""
  end

  def zh_genre=(genre : String)
    genre = fix_tag(genre)
    return if genre.empty? || genre == @zh_genre

    @zh_genre = genre
    @vi_genre = ""
  end

  def zh_tag=(tags : Array(String))
    @zh_tags.clear
    @vi_tags.clear
    add_tags(tags)
  end

  def add_tags(tags : Array(String))
    return if tags.empty?
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty?

    case tag = fix_tag(tag)
    when @zh_genre, @zh_author, @zh_title
      return
    else
      return if @zh_tags.includes?(tag)

      @zh_tags << tag
      @vi_tags << ""
    end
  end

  def fix_tag(tag : String)
    return tag if tag.empty? || tag == "轻小说"
    tag.sub("小说", "")
  end

  def add_cover(cover : String)
    return if cover.empty? || @covers.includes?(cover)
    @covers << cover
  end

  def set_status(status : Int32) : Void
    @status = status if status > @status
  end

  def set_mftime(mftime : Int64) : Void
    @mftime = mftime if mftime > @mftime
  end

  def reset_weight!
    @weight = (@voters * @rating * 2).round / 2
  end

  def to_s(io : IO)
    to_json(io)
  end

  # class methods

  ROOT = File.join("var", "appcv", "book_infos")

  def self.path(uuid : String)
    File.join(ROOT, "#{uuid}.json")
  end

  def self.load!(title : String, author : String) : BookInfo
    uuid = Utils.gen_uuid(title, author)
    load(uuid) || new(title, author, uuid)
  end

  def self.load(uuid : String) : BookInfo?
    file = path(uuid)
    read!(file) if File.exists?(file)
  end

  def self.load!(uuid : String) : BookInfo
    read!(path(uuid))
  end

  def self.read!(file : String) : BookInfo
    from_json(File.read(file))
  end

  def self.save!(info : BookInfo, file = path(info.uuid)) : Void
    File.write(file, info.to_json)
  end

  def self.load_all
    infos = {} of String => BookInfo

    files = Dir.glob(File.join(ROOT, "*.json"))
    files.each do |file|
      uuid = File.basename(file, ".json")
      infos[uuid] = read!(file)
    end

    puts "- <book_info> loaded `#{files.size.colorize(:cyan)}` entries."
    infos
  end
end
