require "colorize"
require "file_utils"

require "../common/json_data"
require "../common/uuid_util"

require "./book_seed"

class BookInfo
  include JsonData

  property ubid = ""
  property slug = ""

  property zh_title = ""
  property vi_title = ""
  property hv_title = ""

  property zh_author = ""
  property vi_author = ""

  property zh_intro = ""
  property vi_intro = ""

  property zh_genres = {} of String => String
  property vi_genres = [] of String

  property zh_tags = {} of String => String
  property vi_tags = [] of String

  property cover_urls = {} of String => String
  property main_cover = ""

  property voters = 0_i32
  property rating = 0_f32
  property weight = 0_i64

  property shield = 0_i32
  property status = 0_i32
  property mftime = 0_i64

  property yousuu_bid = ""
  property origin_url = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property view_count = 0_i32
  property read_count = 0_i32

  property seeds = {} of String => BookSeed

  def initialize
  end

  def initialize(@zh_title : String, @zh_author : String, @ubid = "")
    fix_ubid if @ubid.empty?
    @changes = 1
  end

  # regenerate ubid
  def fix_ubid : Void
    self.ubid = UuidUtil.gen_ubid(@zh_title, @zh_author)
  end

  # add new zh_genre if not already exists
  def add_zh_genre(site : String, genre : String) : Void
    return if @zh_genres[site]? == genre

    @changes += 1
    @zh_genres[site] = genre
  end

  # add new vi_genre if not already exists
  def add_vi_genre(genre : String) : Void
    return if @vi_genres.includes?(genre)

    @changes += 1
    @vi_genres << genre_vi
  end

  # add new zh_tag if not already exists
  def add_zh_tags(site : String, tags : String) : Void
    return if @zh_tags[site]? == tags

    @changes += 1
    @zh_tags[site] = tags
  end

  # add new vi_tag if not already exists
  def add_vi_tag(vi_tag : String) : Void
    return if @vi_tags.includes?(vi_tag)
    @changes += 1
    @vi_tags << vi_tag
  end

  # only add cover if not already exists
  def add_cover(site : String, cover : String)
    return if @cover_urls[site]? == cover

    @changes += 1
    @cover_urls[site] = cover
  end

  # transform rating to integer based score (0 to 100)
  def scored
    (@rating * 10).to_i64
  end

  # recaculate book worth
  def get_weight
    scored * @voters + @view_count
  end

  def set_weight(weight = get_weight)
    self.weight = weight
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

  # generate unique book id from `zh_title` and `zh_author`
  def self.ubid_for(title : String, author : String) : String
    UuidUtil.gen_ubid(title, author)
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

  # create new entry if book with this `zh_title` and `zh_author` does not exist
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
    CACHE[ubid] ||= get_or_create(title, author, ubid)
  end

  # loadd all entries in to `CACHE`
  def self.preload_all!
    files.each { |file| CACHE[ubid_for(file)] = read!(file) }
    puts "- <book_info> loaded all entries to cache (size: #{CACHE.size.colorize.green})."
    CACHE
  end
end
