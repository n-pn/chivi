require "json"
require "colorize"
require "file_utils"

require "./serials/*"
require "../../src/kernel/chlists"

# File.write "data/txt-tmp/existed.txt", inputs.keys.join("\n")

books = Array(MyBook).from_json(File.read("data/txt-tmp/serials.json"))

puts "- books: #{books.size} entries".colorize(:cyan)

FileUtils.rm_rf("data/txt-out/serials")
FileUtils.mkdir_p("data/txt-out/serials")
FileUtils.mkdir_p("data/txt-out/serials/indexes")
FileUtils.rm_rf("data/txt-out/chlists")
FileUtils.mkdir_p("data/txt-out/chlists")

# puts "- converting...".colorize(:cyan)

mapping = {} of String => String
missing = [] of String
hastext = [] of String

tally = [] of Tuple(String, Float64)
score = [] of Tuple(String, Float64)
votes = [] of Tuple(String, Int32)
update = [] of Tuple(String, Int64)

# authors = Hash(String, Array(String)).new do |h, k|
#   h[k] = [] of String
# end

CTIME = ((ARGV[0]? || "10").to_i? || 10).days
CLIST = Chlists.new

books.each_with_index do |book, idx|
  book.translate!
  File.write "data/txt-out/serials/#{book.vi_slug}.json", book.to_pretty_json

  slug = book.vi_slug
  site = book.prefer_site
  bsid = book.prefer_bsid

  mapping[book.zh_slug] = slug
  if site.empty?
    puts "- <#{idx + 1}/#{books.size}> [#{slug}]".colorize(:blue)
    missing << slug
  else
    hastext << slug
    tally << {slug, book.tally}
    score << {slug, book.score}
    votes << {slug, book.votes}
    update << {slug, book.updated_at}

    crawler = CrInfo.new(site, bsid, book.updated_at)

    if site == "zhwenpg" || crawler.cached?(CTIME)
      crawler.load_cached!(serial: true, chlist: true)
    else
      crawler.reset_cache(html: true)
      crawler.mkdirs!
      crawler.crawl!(label: "#{idx + 1}/#{books.size}")
    end

    chlist = crawler.chlist
    puts "- <#{idx + 1}/#{books.size}> [#{slug}/#{site}/#{bsid}]: #{chlist.size} chapters".colorize(:blue)
    CLIST.save(site, bsid, chlist)
  end
end

puts "- Save indexes...".colorize(:cyan)

File.write "data/txt-out/serials.json", books.to_pretty_json
File.write "data/txt-out/mapping.json", mapping.to_pretty_json

File.write "data/txt-out/serials/indexes/tally.json", tally.sort_by(&.[1].-).to_pretty_json
File.write "data/txt-out/serials/indexes/score.json", score.sort_by(&.[1].-).to_pretty_json
File.write "data/txt-out/serials/indexes/votes.json", votes.sort_by(&.[1].-).to_pretty_json
File.write "data/txt-out/serials/indexes/update.json", update.sort_by(&.[1].-).to_pretty_json

puts "- MISSING: #{missing.size}"
File.write "data/txt-out/serials/indexes/missing.txt", missing.join("\n")

puts "- HASTEXT: #{hastext.size}"
File.write "data/txt-out/serials/indexes/hastext.txt", hastext.join("\n")
