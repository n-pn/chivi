require "json"
require "time"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/crawls/cr_info.cr"

REQUIRE_HTML = ARGV.includes?("require_html")

def fetch_info(channel, site, bsid, label = bsid.to_i) : Void
  crawler = CrInfo.new(site, bsid)
  if crawler.cached?(300.days, require_html: REQUIRE_HTML)
    crawler.load_cached!(chlist: false)
  else
    crawler.crawl!(label: label)
  end

  serial = crawler.serial
  channel.send({bsid, serial.slug, serial.updated_at})
rescue err
  # crawler.reset_cache
  puts "- crawl [#{bsid.colorize(:red)}] failed: <#{err.class}> #{err.colorize(:red)}"
  channel.send({bsid, "--", 0_i64})
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

def mapping(sitemap, updates, result) : Void
  bsid, slug, time = result

  return if slug == "--"

  if old_bsid = sitemap[slug]?
    if old_bsid != bsid
      puts "DUP [#{slug.colorize(:blue)}]: <#{old_bsid} <=> #{bsid}>"
    end

    if old_time = updates[slug]?
      return if old_time > time
    end
  end

  updates[slug] = time
  sitemap[slug] = bsid
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

updates = {} of String => Int64
sitemap = {} of String => String
if File.exists?(out_file)
  sitemap = Hash(String, String).from_json File.read(out_file)
end

alias Result = Tuple(String, String, Int64)
channel = Channel(Result).new(worker)

total = upto - from + 1
from.upto(upto) do |idx|
  mapping(sitemap, updates, channel.receive) if idx - from >= worker
  spawn { fetch_info(channel, site, idx.to_s, "#{idx}/#{total}") }
end

worker.times { mapping(sitemap, updates, channel.receive) }

File.write out_file, sitemap.to_pretty_json
