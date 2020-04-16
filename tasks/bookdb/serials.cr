require "json"
require "colorize"
require "file_utils"

require "../../src/entity/sbook"
require "../../src/entity/ybook"
require "../../src/entity/vbook"
require "../../src/entity/vsite"

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

def shorten_label_us(book)
  title_us = book.title.us
  if title_us.size > 4 && !USED_SLUGS.includes?(title_us)
    book.label.us = title_us
    USED_SLUGS << title_us
  else
    raise "DUP #{book.label}!!!" if USED_SLUGS.includes?(book.label.us)
    USED_SLUGS << book.label.us
  end
end

inputs = Array(YBook).from_json(File.read("data/txt-tmp/yousuu/serials.json"))
puts "- input: #{inputs.size} entries".colorize(:blue)

existed = Set(String).new

SERIAL_DIR = "data/txt-out/serials"
FileUtils.rm_rf(SERIAL_DIR)
FileUtils.mkdir_p(SERIAL_DIR)

inputs.each_with_index do |ybook, idx|
  existed << ybook.label

  book = VBook.new(ybook)
  sitemaps.each do |site, map|
    if link = map[book.label.zh]?
      book.update(SBook.load(site, link.bsid))
    end
  end

  shorten_label_us(book)

  print "<#{idx + 1}/#{inputs.size}>"
  book.save!
  outputs << book
end

puts "- yousuu: #{outputs.size} entries".colorize(:cyan)

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

  votes, score = ratings[input.label]? || {Random.rand(200..300), Random.rand(60..70)/10}

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

  shorten_label_us(book)

  print "<#{idx + 1}/#{files.size}>"
  book.save!

  outputs << book
end

puts "- output: #{outputs.size} entries".colorize(:cyan)
