require "json"
require "colorize"
require "file_utils"

require "../../src/crawls/cr_info"
require "../../src/models/vp_book"

class BookSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class BookInfo
  include JSON::Serializable

  property _id : Int32
  property title : String?
  property author : String?

  @[JSON::Field(key: "introduction")]
  property intro : String = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?
  property tags : Array(String)
  property cover : String = ""
  property status : Int32 = 0
  property shielded : Bool

  @[JSON::Field(key: "countWord")]
  property word_count : Float64 = 0

  @[JSON::Field(key: "commentCount")]
  property review_count : Int32 = 0

  @[JSON::Field(key: "scorerCount")]
  property votes : Int32
  property score : Float64 = 0.0

  @[JSON::Field(key: "updateAt")]
  property updated_at : Time = Time.utc(2020, 1, 1)

  property _sources : Array(String) = [] of String

  def slug
    "#{title}--#{author}"
  end

  def genre
    category ? category.not_nil![:className] : nil
  end

  def hidden
    shielded ? 2 : 0
  end

  def tally
    (votes * score * 2).round / 2
  end

  FIX_TITLES  = Hash(String, String).from_json(File.read("data/txt-inp/yousuu/fix-titles.json"))
  FIX_AUTHORS = Hash(String, String).from_json(File.read("data/txt-inp/yousuu/fix-authors.json"))

  alias Data = NamedTuple(bookInfo: BookInfo, bookSource: Array(BookSource))

  def self.from_json_file(data : String)
    json = NamedTuple(data: Data).from_json(data)

    info = json[:data][:bookInfo]
    info._sources = json[:data][:bookSource].map(&.link)

    if title = FIX_TITLES[info.title || ""]?
      info.title = title
    end

    if author = info.author
      if fixed_author = FIX_AUTHORS[info.title || ""]?
        info.author = fixed_author
      else
        info.author = author.sub(".QD", "").strip
      end
    end

    info
  end
end

class MyBook < VpBook
  def initialize(books : Array(BookInfo))
    books = books.sort_by { |x| {x.hidden, -x.updated_at.to_unix_ms} }
    first = books.first

    @zh_title = first.title.as(String)
    @zh_author = first.author.as(String)
    @zh_slug = first.slug.as(String)
    @hidden = first.hidden

    @word_count = first.word_count.round.to_i
    @review_count = first.review_count
    if first.updated_at > Time.utc
      @updated_at = Time.utc(2010, 1, 1).to_unix_ms
    else
      @updated_at = first.updated_at.to_unix_ms
    end

    books.each do |book|
      # next if book.hidden > 0
      @zh_intro = book.intro if @zh_intro.empty?

      if genre = book.genre
        if @zh_genre.empty?
          @zh_genre = genre
        else
          @zh_tags << genre
        end
      end

      if cover = book.cover
        @covers << cover if cover.starts_with?("http")
      end

      @votes += book.votes
      @tally += book.tally

      @yousuu_bids << book._id
      @source_urls.concat book._sources
    end

    @covers.uniq!
    @source_urls.uniq!

    if @votes > 0
      @score = (@tally * 10 / @votes).round / 10
    else
      @score = 0.0
    end
  end

  def initialize(input : CrInfo::Serial, @votes, @score, @word_count = 0)
    @zh_slug = "#{input.title}--#{input.author}"

    @zh_title = input.title
    @zh_author = input.author

    @zh_intro = input.intro || ""
    @zh_genre = input.genre

    @covers = [input.cover]
    @status = 0
    @hidden = 1

    @tally = (@votes * @score * 2).round / 2

    @word_count = word_count
    @chap_count = input.chap_count
    @updated_at = input.updated_at
  end

  def translate!
    @vi_title = map_title(@zh_title)
    @vi_author = CUtil.titlecase(MyUtil.hanviet(@zh_author))

    @vi_slug = pick_slug(@vi_title, @vi_author)

    format_intro!
    @vi_intro = @zh_intro.split("\n").map { |x| MyUtil.translate(x) }.join("\n")

    @vi_genre, move_to_tag = map_genre(@zh_genre)
    @zh_tags << @zh_genre if move_to_tag

    clean_tags!
    @vi_tags = @zh_tags.map { |x| MyUtil.translate(x) }
  end

  TITLES_MAP = Hash(String, Array(String)).from_json(File.read("data/txt-inp/titles-map.json"))

  def map_title(zh_title)
    if titles = TITLES_MAP[zh_title]?
      return titles[0]
    else
      CUtil.capitalize(MyUtil.hanviet(zh_title))
    end
  end

  GENRES_MAP = Hash(String, Tuple(String, Bool)).from_json File.read("data/txt-inp/genres-map.json")

  def map_genre(genre : String?)
    GENRES_MAP.fetch(genre || "", {"Loại khác", false})
  end

  USED_SLUGS = Set(String).new

  def pick_slug(vi_title, vi_author)
    title_slug = CUtil.slugify(vi_title, no_accent: true)
    author_slug = CUtil.slugify(vi_author, no_accent: true)
    full_slug = "#{title_slug}--#{author_slug}"

    if USED_SLUGS.includes?(title_slug) || title_slug.size < 5
      output = full_slug
    else
      output = title_slug
    end

    if USED_SLUGS.includes?(output)
      puts "USED SLUG #{output}"
      exit 1
    end

    USED_SLUGS << output
    output
  end
end

files = Dir.glob("data/txt-inp/yousuu/serials/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

inputs = Hash(String, Array(BookInfo)).new { |h, k| h[k] = [] of BookInfo }

files.each do |file|
  data = File.read(file)

  if data.includes?("{\"success\":true,")
    info = BookInfo.from_json_file(data)
    next unless info.title && info.author

    inputs[info.slug] << info
  elsif data.includes?("未找到该图书")
    # puts "- [#{file}] is 404!".colorize(:blue)
  else
    puts "- [#{file}] malformed!".colorize(:red)
    File.delete(file)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
end

# File.write "data/txt-tmp/existed.txt", inputs.keys.join("\n")

CACHE_TIME = ((ARGV[0]? || "10").to_i? || 10).days

def merge_other(target : MyBook, site : String, bsid : String) : MyBook
  serial_file = "data/txt-tmp/serials/#{site}/#{bsid}.json"
  serial = CrInfo::Serial.from_json(File.read(serial_file))

  if cover = serial.cover
    target.covers << cover unless cover.empty?
  end

  target.zh_intro = serial.intro if target.zh_intro.empty?

  if target.zh_genre.empty?
    target.zh_genre = serial.genre
  elsif serial.genre != target.zh_genre
    target.zh_tags << serial.genre unless serial.genre.empty?
  end

  target.zh_tags.concat(serial.tags)

  target.status = serial.status if target.status < serial.status
  target.chap_count = serial.chap_count if target.chap_count == 0

  target.crawl_links[site] = bsid

  if target.prefer_site.empty?
    target.prefer_site = site
    target.prefer_bsid = bsid
  end

  target.updated_at = serial.updated_at if target.updated_at < serial.updated_at

  target
end

puts "- Merging with other sites..."

def load_sitemap(site)
  inp = "data/txt-tmp/sitemap/#{site}.json"
  map = Hash(String, String).from_json File.read(inp)

  puts "- <#{site}>: #{map.size} entries".colorize(:cyan)

  dir = "data/txt-tmp/sitemap/#{site}/"
  return map unless File.exists? dir

  bsids = Dir.children(dir).map { |x| File.basename(x, ".txt") }
  items = Set(String).new(bsids)

  map.reject! { |key, val| items.includes?(val) }
  puts "- <#{site}> ignore blacklist: #{map.size} entries".colorize(:cyan)

  map
end

sitemaps = {} of String => Hash(String, String)

SITES = [
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
]
SITES.each { |site| sitemaps[site] = load_sitemap(site) }

outputs = [] of MyBook

inputs.map do |slug, books|
  book = MyBook.new(books)
  next if book.tally < 50

  puts "- #{slug}".colorize(:cyan)

  sitemaps.each do |site, map|
    if bsid = map[book.zh_slug]?
      book = merge_other(book, site, bsid)
    end
  end

  outputs << book
end

puts "- yousuu: #{outputs.size} entries".colorize(:cyan)

existed = Set(String).new inputs.keys
existed.concat File.read_lines("data/txt-inp/labels-ignore.txt")
ratings = Hash(String, Tuple(Int32, Float64)).from_json File.read("data/txt-inp/zhwenpg/ratings.json")

files = Dir.glob("data/txt-tmp/serials/zhwenpg/*.json")
files.each_with_index do |file, idx|
  input = CrInfo::Serial.from_json(File.read(file))
  next if existed.includes?(input.slug)

  votes, score = ratings[input.slug]

  word_count = input.word_count
  if word_count == 0
    files = "data/txt-tmp/chtexts/zhwenpg/#{input._id}/*.txt"
    word_count = Dir.glob(files).map { |file| File.read(file).size }.sum
  end

  book = MyBook.new(input, votes, score, word_count)

  sitemaps.each do |site, map|
    next if site == "zhwenpg"

    if bsid = map[book.zh_slug]?
      book = merge_other(book, site, bsid)
    end
  end

  outputs << book
end

puts "- output: #{outputs.size} entries".colorize(:cyan)

outputs.sort_by!(&.tally.-)
outputs.each do |output|
  output.covers = output.covers.uniq.map do |url|
    url = url.sub("qu.la", "jx.la")
    if url.starts_with?("http://image.qidian.com")
      url = url.sub("http://image.qidian.com/books", "https://qidian.qpic.cn/qdbimg").sub(".jpg", "/300.jpg")
    end

    url
  end
end

File.write "data/txt-tmp/serials.json", outputs.to_pretty_json
