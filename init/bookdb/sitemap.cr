require "json"
require "time"
require "colorize"
require "option_parser"

require "../../src/crawls/cr_info.cr"

REQUIRE_HTML = ARGV.includes?("require_html")

def fetch_info(channel, site, bsid, label = bsid.to_i) : Void
  crawler = CrInfo.new(site, bsid)
  begin
    if crawler.cached?(300.days, require_html: REQUIRE_HTML)
      crawler.load_cached!(chlist: false)
    else
      crawler.crawl!(label: label)
    end

    serial = crawler.serial
    channel.send({bsid, serial.slug, serial.updated_at})
  rescue err
    crawler.reset_cache
    puts "- crawl [#{bsid.colorize(:red)}] failed: #{err.colorize(:red)}"

    channel.send({bsid, "", 0_i64})
  end
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

UPDATES = {} of String => Int64
SITEMAP = {} of String => String

def mapping(result) : Void
  bsid, slug, time = result

  return if slug.empty?

  if old = SITEMAP[slug]?
    puts "DUP [#{slug.colorize(:blue)}]: <#{old} <=> #{bsid}>"
    return if UPDATES[slug] > time
  end

  UPDATES[slug] = time
  SITEMAP[slug] = bsid
end

range = upto - from + 1
worker = range if worker > range

puts "CONFIG: { \
  site: #{site.colorize(:yellow)}, \
  from: #{from.colorize(:yellow)}, \
  upto: #{upto.colorize(:yellow)}, \
  worker: #{worker.colorize(:yellow)} \
}"

alias Result = Tuple(String, String, Int64)
channel = Channel(Result).new(worker)

total = upto - from + 1
from.upto(upto) do |idx|
  mapping(channel.receive) if idx > worker
  spawn { fetch_info(channel, site, idx.to_s, "#{idx}/#{total}") }
end

worker.times { mapping(channel.receive) }

File.write "data/txt-tmp/sitemap/#{site}.json", SITEMAP.to_pretty_json
