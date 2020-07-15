require "colorize"
require "file_utils"

require "../common/json_data"
require "./book_seed"
require "./book_util"

class BookInfo
  include JsonData

  property ubid = ""
  property slug = ""

  property title_zh = ""
  property title_vi = ""
  property title_hv = ""

  property author_zh = ""
  property author_vi = ""

  property intro_zh = ""
  property intro_vi = ""

  property genres_zh = [] of String
  property genres_vi = [] of String

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

  property yousuu_bid = ""
  property origin_url = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property view_count = 0_i32
  property read_count = 0_i32

  property seeds = {} of String => BookSeed

  def initialize
  end

  def initialize(@title_zh : String, @author_zh : String, @ubid = "")
    if @ubid.empty?
      fix_ubid
    else
      @changes = 1
    end
  end

  # regenerate ubid
  def fix_ubid : Void
    self.ubid = BookInfo.ubid_for(@title_zh, @author_zh)
  end

  # add new genre if not already exists
  def add_genre(genre_zh : String, genre_vi = "") : Void
    return if genre_zh.empty? || @genres_zh.includes?(genre_zh)
    @changes += 1

    @genres_zh << genre_zh
    @genres_vi << genre_vi
  end

  # calling `add_tag(tag)` for each tag
  def add_tags(tags : Array(String))
    tags.each { |tag| add_tag(tag) }
  end

  # add new tag if not already exists
  def add_tag(tag_zh : String, tag_vi = "") : Void
    return if tag_zh.empty? || @tags_zh.includes?(tag_zh)
    @changes += 1

    @tags_zh << tag_zh
    @tags_vi << tag_vi
  end

  # only add cover if not already exists
  def add_cover(cover : String)
    return if cover.empty? || @cover_urls.includes?(cover)
    @changes += 1
    @cover_urls << cover
  end

  # transform rating to integer based score (0 to 100)
  def scored
    (@rating * 10).to_i64
  end

  # recaculate book worth
  def fix_weight
    @weight = scored * @voters + @view_count
  end

  def update(source : YsSerial)
    source.genres.each do |(genre_zh, genre_vi)|
      add_genre(genres_zh, genre_vi)
    end

    source.tags.each do |tag|
      add_tag(tag)
    end
  end

  # update info from remote seed source
  def update(source : SeedInfo)
    genres = BookUtil.map_genre(source.genre)
      .source.genres.each do |(genre_zh, genre_vi)|
      add_genre(genres_zh, genre_vi)
    end

    source.tags.each do |tag|
      add_tag(tag)
    end

    set_intro(source.intro) if @intro_zh.empty?
    add_cover(source.cover)

    seed = put_seed(source.seed, source.type)
    seed.update_remote(source)

    self.mftime = seed.mftime if @mftime < seed.mftime
    self.status = seed.status if @status < seed.status

    @changes += seed.reset_changes!
  end

  # create new seed if not existed
  def put_seed(name : String, type = 1)
    @seeds[name] ||= BookSeed.new(name, type)
  end

  # json serialization
  def to_s
    String.build { |io| to_s(io) }
  end

  # :ditto:
  def to_s(io : IO)
    to_json(io)
  end

  # save file and reset change counter
  def save!(file : String = BookInfo.path_for(@ubid)) : Void
    color = changed? ? :yellow : :cyan
    puts "- <book_info> [#{file.colorize(color)}] saved \
    (changes: #{@changes.colorize(color)})."

    @changes = 0
    File.write(file, self)
  end

  # class methods

  DIR = File.join("var", "bookdb", "infos")
  FileUtils.mkdir_p(DIR)

  # all book infos file in the `DIR` folder
  def self.files : Array(String)
    Dir.glob(File.join(DIR, "*.json"))
  end

  # all existed books (identity by its `ubid`) inside data folder
  def self.ubids : Array(String)
    files.map { |x| ubid_for(x) }
  end

  # generate file path of the book in the data folder
  def self.path_for(ubid : String) : String
    File.join(DIR, "#{ubid}.json")
  end

  # extract ubid from filename
  def self.ubid_for(file : String) : String
    File.basename(file, ".json")
  end

  # generate unique book id from `title_zh` and `author_zh`
  def self.ubid_for(title : String, author : String) : String
    Utils.gen_ubid(title, author)
  end

  # check if book with this `ubid` exists
  def self.exists?(ubid : String) : Bool
    File.exists?(path_for(ubid))
  end

  # return true if book info not found or has mtime smaller than `time`
  def self.outdated?(ubid : String, time : Time)
    file = path_for(ubid)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end

  # read book info file if exists, raise error if not found
  def self.read!(file : String) : BookInfo
    read(file) || raise "<book_info> file [#{file}] not found!"
  end

  # read file if exists, return nil if error, delete file if parsing error.
  def self.read(file : String) : BookInfo?
    return unless File.exists?(file)
    # puts "- <book_info> [#{file.colorize.blue}] loaded."
    from_json(File.read(file))
  rescue err
    puts "- <book_info> error parsing file [#{file}], err: #{err}".colorize.red
    File.delete(file)
    nil
  end

  # load book info by its `ubid`
  def self.get(ubid : String) : BookInfo?
    read(path_for(ubid))
  end

  # load book info by its `ubid`, raise error if not found.
  def self.get!(ubid : String) : BookInfo
    get(ubid) || raise "<book_info> book with ubid [#{ubid}] not found!"
  end

  # find book info by `title` and `author`, raise error if not found.
  def self.get!(title : String, author : String) : BookInfo
    get!(title, author) || raise "<book_info> book [#{title}-#{author}] not found!"
  end

  # find book info by using `title` and `author` as unique identity
  def self.get(title : String, author : String) : BookInfo?
    get(ubid_for(title, author))
  end

  # create new entry if book with this `title_zh` and `author_zh` does not exist
  # can reuse `ubid` if pre-calculated
  def self.get_or_create(title : String, author : String, ubid : String? = nil)
    ubid ||= ubid_for(title, author)
    get(ubid) || new(title, author, ubid)
  end

  # load all book infos from `DIR` folder
  def self.load_all!(list = [] of BookInfo) : Array(BookInfo)
    files.each { |file| list << read!(file) }
    puts "- <book_info> loaded all entries (size: #{list.size.colorize.green})."
    list
  end

  # cache book infos for faster access and consistency
  CACHE = {} of String => BookInfo

  # load with caching, raise error if book with this ubid does not exists.
  def self.preload!(ubid : String) : BookInfo
    CACHE[ubid] ||= load!(ubid)
  end

  # load with caching, create new entry if not exists
  def self.preload_or_create!(title : String, author : String, ubid : String? = nil) : BookInfo
    ubid ||= ubid_for(title, author)
    CACHE[ubid] ||= find_or_create(title, author, ubid)
  end

  # loadd all entries in to `CACHE`
  def self.preload_all!
    files.each { |file| CACHE[ubid_for(file)] = read!(file) }
    puts "- <book_info> loaded all entries to cache (size: #{CACHE.size.colorize.green})."
    CACHE
  end
end
