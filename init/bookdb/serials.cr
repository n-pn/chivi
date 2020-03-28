require "json"
require "colorize"
require "file_utils"

require "../src/models/vp_book"
require "../src/crawls/cr_info"

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
    @updated_at = first.updated_at.to_unix_ms

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
end

files = Dir.glob("data/txt-inp/yousuu/serials/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

inputs = Hash(String, Array(BookInfo)).new { |h, k| h[k] = [] of BookInfo }

files.each do |file|
  begin
    data = File.read(file)

    if data.includes?("{\"success\":true,")
      info = BookInfo.from_json_file(data)
      next unless info.title && info.author

      inputs[info.slug] << info
    elsif data.includes?("未找到该图书")
      # puts "- [#{file}] is 404!".colorize(:blue)
    else
      puts "- [#{file}] malformed!".colorize(:red)
      File.delete file
    end
  rescue err
    puts "#{file} err: #{err}".colorize(:red)
  end
end

File.write "data/txt-tmp/existed.txt", inputs.keys.join("\n")

def load_sitemap(site)
  inp = "data/txt-tmp/mapping/#{site}.json"
  map = Hash(String, String).from_json File.read(inp)

  puts "- <#{site}>: #{map.size} entries".colorize(:cyan)

  dir = "data/txt-tmp/mapping/#{site}/"
  return map unless File.exists? dir

  bsids = Dir.children(dir).map { |x| File.basename(x, ".txt") }
  items = Set(String).new(bsids)

  map.reject! { |key, val| items.includes?(val) }
  puts "- <#{site}> ignore blacklist: #{map.size} entries".colorize(:cyan)

  map
end

sitemaps = {} of String => Hash(String, String)

SITES = [
  "jx_la", "rengshu", "hetushu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
]
SITES.each { |site| sitemaps[site] = load_sitemap(site) }

outputs = [] of VpBook

inputs.map do |slug, books|
  book = MyBook.new(books)
  next if book.tally < 100

  # puts "- #{slug}".colorize(:cyan)

  outputs << book
end

puts "- output: #{outputs.size} entries".colorize(:yellow)
