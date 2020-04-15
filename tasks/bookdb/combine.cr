require "json"
require "colorize"
require "file_utils"

require "../../src/spider/info_crawler"
require "../../src/entity/sbook"
require "../../src/entity/ybook"
require "../../src/entity/vbook"
require "../../src/entity/vsite"

files = Dir.glob("data/txt-inp/yousuu/serials/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

inputs = Hash(String, Array(YBook)).new { |h, k| h[k] = [] of YBook }

files.each do |file|
  data = File.read(file)

  if data.includes?("{\"success\":true,")
    book = YBook.load(data)
    next if book.title.empty? || book.author.empty?

    inputs[book.label] << book
  elsif data.includes?("未找到该图书")
    # puts "- [#{file}] is 404!".colorize(:blue)
  else
    puts "- [#{file}] malformed!".colorize(:red)
    File.delete(file)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
  puts data
end

# File.write "data/txt-tmp/existed.txt", inputs.keys.join("\n")

CACHE_TIME = ((ARGV[0]? || "10").to_i? || 10).days

puts "- Merging with other sites..."

def load_sitemap(site)
  inp = "data/txt-tmp/sitemap/#{site}.json"
  map = Hash(String, VSite).from_json(File.read(inp))

  puts "- <#{site}>: #{map.size} entries".colorize(:cyan)

  dir = "data/txt-tmp/sitemap/#{site}/"
  return map unless File.exists? dir

  bsids = Dir.children(dir).map { |x| File.basename(x, ".txt") }
  items = Set(String).new(bsids)

  map.reject! { |key, val| items.includes?(val.bsid) }
  puts "- <#{site}> ignore blacklist: #{map.size} entries".colorize(:cyan)

  map
end

sitemaps = {} of String => Hash(String, VSite)

SITES = [
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
]
SITES.each { |site| sitemaps[site] = load_sitemap(site) }

outputs = [] of VBook

USED_SLUGS = Set(String).new

def fix_label(book)
  title_us = book.title.us
  if title_us.size > 4 && !USED_SLUGS.includes?(title_us)
    book.label.us = title_us
    USED_SLUGS << title_us
  else
    raise "DUP #{book.label}!!!" if USED_SLUGS.includes?(book.label.us)
    USED_SLUGS << book.label.us
  end
end

inputs.map do |slug, books|
  books = books.sort_by { |x| {x.hidden, -x.mtime} }
  first = books.first

  books[1..].each { |other| first.merge(other) }
  next if first.tally < 50

  book = VBook.new(first)

  # puts "- #{slug}".colorize(:cyan)

  sitemaps.each do |site, map|
    if link = map[book.label.zh]?
      book.update(SBook.load(site, link.bsid))
    end
  end

  fix_label(book)

  book.save!
  outputs << book
end

puts "- yousuu: #{outputs.size} entries".colorize(:cyan)

existed = Set(String).new inputs.keys
existed.concat File.read_lines("data/txt-inp/labels-ignore.txt")
ratings = Hash(String, Tuple(Int32, Float64)).from_json File.read("data/txt-inp/zhwenpg/ratings.json")

class VBook
  def initialize(other : SBook)
    set_title(other.title)
    set_author(other.author)
    set_label()

    @status = other.status
    @mtime = other.mtime
  end
end

files = Dir.glob("data/txt-tmp/serials/zhwenpg/*.json")
files.each_with_index do |file, idx|
  input = SBook.load(file)
  next if existed.includes?(input.label)

  votes, score = ratings[input.label]

  files = "data/txt-tmp/chtexts/zhwenpg/#{input.bsid}/*.txt"
  word_count = Dir.glob(files).map { |file| File.read(file).size }.sum

  book = VBook.new(input)
  book.hidden = 1
  book.votes = votes
  book.score = score
  book.tally = (votes * score * 2).round / 2
  book.word_count = word_count

  sitemaps.each do |site, map|
    if link = map[book.label.zh]?
      book.update(SBook.load(site, link.bsid))
    end
  end

  fix_label(book)
  book.save!
  outputs << book
end

puts "- output: #{outputs.size} entries".colorize(:cyan)

# outputs.sort_by!(&.tally.-)
# File.write "data/txt-tmp/serials.json", outputs.to_pretty_json
