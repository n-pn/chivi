require "json"
require "colorize"
require "file_utils"

# require "../../src/crawls/cr_info"
# require "../../src/models/vp_book"
require "../../src/kernel/chlists"

CACHE_TIME = (ARGV[0]? || "10").to_i? || 10

puts "- Save chlists (cached: #{CACHE_TIME} hours)...".colorize(:cyan)

chlists = Chlists.new

files = Dir.glob("data/txt-out/serials/*.json")
files.each_with_index do |file, idx|
  book = VpBook.from_json(File.read(file))
  next if book.favor_crawl.empty?
  list = chlists.get(book, time: Time.utc - CACHE_TIME.hours)
  puts "- <#{idx + 1}/#{files.size}> [#{book.vi_slug}/#{book.favor_crawl}/#{book.crawl_bsid}]: #{list.size} chapters".colorize(:blue)
rescue err
  puts err
end
