require "json"
require "time"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/spider/info_crawler.cr"
require "../../src/entity/vsite.cr"

REQUIRE_HTML = ARGV.includes?("require_html")

alias Result = Tuple(String, VSite)

def fetch_info(site, bsid, label = "1/1") : Result
  crawler = InfoCrawler.new(site, bsid)
  if crawler.cached?(300.days, require_html: REQUIRE_HTML)
    crawler.load_cached!(slist: false)
  else
    crawler.crawl!(persist: true, label: label)
  end

  info = crawler.sbook
  {info.label, VSite.new(bsid, info.mtime, info.chaps)}
rescue err
  # crawler.reset_cache
  puts "- crawl [#{bsid.colorize(:red)}] failed: <#{err.class}> #{err.colorize(:red)}"
  {"--", VSite.new(bsid)}
end

site = "rengshu"
from = 1
upto = 4275
worker = 12

OptionParser.parse do |parser|
  parser.banner = "Usage: mapping [arguments]"
  parser.on("-h", "--help", "Show this help") { puts parser }

  parser.on("-s SITE", "--site=SITE", "Site") { |x| site = x }
  parser.on("-f FROM", "--from=FROM", "From") { |x| from = x.to_i }
  parser.on("-t UPTO", "--upto=UPTO", "Upto") { |x| upto = x.to_i }

  parser.on("-w WORKER", "--worker=WORKER", "Worker") { |x| worker = x.to_i }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

def mapping(sitemap, result) : Void
  slug, site = result
  return if slug == "--"

  if old_site = sitemap[slug]?
    if old_site.bsid != site.bsid
      puts "DUP [#{slug.colorize(:blue)}]: <#{old_site} <=> #{site}>"
    end

    return if old_site.mtime > site.mtime
  end

  sitemap[slug] = site
end

range = upto - from + 1
worker = range if worker > range

puts "CONFIG: { \
  site: #{site.colorize(:yellow)}, \
  from: #{from.colorize(:yellow)}, \
  upto: #{upto.colorize(:yellow)}, \
  worker: #{worker.colorize(:yellow)} \
}"

FileUtils.mkdir_p "data/txt-inp/#{site}/infos"
FileUtils.mkdir_p "data/txt-tmp/serials/#{site}"
FileUtils.mkdir_p "data/txt-tmp/chlists/#{site}"
FileUtils.mkdir_p "data/txt-tmp/sitemap"

out_file = "data/txt-tmp/sitemap/#{site}.json"

sitemap = {} of String => VSite
# if File.exists?(out_file)
#   sitemap = Hash(String, String).from_json File.read(out_file)
# end

channel = Channel(Result).new(worker)

total = upto - from + 1
from.upto(upto) do |idx|
  mapping(sitemap, channel.receive) unless idx - from < worker

  spawn do
    result = fetch_info(site, idx.to_s, "#{idx - from}/#{total}")
    channel.send(result)
  end
end

worker.times { mapping(sitemap, channel.receive) }

File.write(out_file, sitemap.to_json)
