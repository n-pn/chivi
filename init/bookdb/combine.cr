require "json"
require "colorize"
require "file_utils"

require "./serials/*"

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

sitemaps = {} of String => Hash(String, String)

SITES = [
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
]
SITES.each { |site| sitemaps[site] = MyUtil.load_sitemap(site) }

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
    if bsid = map[book.zh_slug]?
      book = merge_other(book, site, bsid)
    end
  end

  outputs << book
end

puts "- output: #{outputs.size} entries".colorize(:cyan)

outputs.sort_by!(&.tally.-)
File.write "data/txt-tmp/serials.json", outputs.to_pretty_json
