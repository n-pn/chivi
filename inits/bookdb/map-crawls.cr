require "json"
require "time"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/crawls/info_parser.cr"

REQUIRE_HTML = ARGV.includes?("require_html")

def fetch_info(channel, site, bsid, label = "1/1") : Void
  parser = InfoParser.load(site, bsid, expiry: 60.days, frozen: true)

  infos = parser.get_infos!
  info_file = File.join("data", "appcv", "zhinfos", site, "#{bsid}.json")
  File.write(info_file, infos.to_pretty_json)

  puts "- <#{label.colorize(:blue)}> [#{infos.label.colorize(:blue)}]"
  channel.send(infos)
rescue err
  puts "- <#{label.colorize(:red)}> [#{site}/#{bsid.colorize(:red)}] \
          ERROR: <#{err.class}> #{err.colorize(:red)}"
  channel.send(nil)
end

site = "rengshu"
from = 1
upto = 4275
worker = 12

OptionParser.parse do |parser|
  parser.banner = "Usage: mapping [arguments]"
  parser.on("-h", "--help", "Show this help") { puts parser }

  parser.on("-s SITE", "--site=SITE", "Site") { |x| site = x }
  parser.on("-t UPTO", "--upto=UPTO", "Upto") { |x| upto = x.to_i }

  parser.on("-w WORKER", "--worker=WORKER", "Worker") { |x| worker = x.to_i }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

puts "- CONFIG: { \
  site: #{site.colorize(:yellow)}, \
  upto: #{upto.colorize(:yellow)}, \
  worker: #{worker.colorize(:yellow)} \
}"

FileUtils.mkdir_p(File.join("data", "appcv", "zhinfos", site))
FileUtils.mkdir_p(File.join("data", "appcv", "zhchaps", site))

alias Mapping = NamedTuple(bsid: String, title: String, author: String, mtime: Int64)

infos = [] of ZhInfo?

channel = Channel(ZhInfo?).new(worker)

1.upto(upto).each_with_index do |bsid, idx|
  infos << channel.receive unless idx < worker

  spawn do
    fetch_info(channel, site, bsid.to_s, "#{idx + 1}/#{upto}")
  end
end

worker.times { infos << channel.receive }

sitemap = Hash(String, Mapping).new

infos.each do |info|
  next unless info
  if mapped = sitemap[info.hash]?
    next if mapped[:mtime] >= info.mtime
  end

  sitemap[info.hash] = {
    bsid:   info.bsid,
    title:  info.title,
    author: info.author,
    mtime:  info.mtime,
  }
end

map_file = "data/appcv/sitemap/#{site}.json"
File.write(map_file, sitemap.to_pretty_json)
