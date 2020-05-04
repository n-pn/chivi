require "json"
require "time"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/spider/info_spider.cr"

def fetch_info(channel, site, bsid, label = "1/1") : Void
  spider = InfoSpider.load(site, bsid, expiry: 60.days, frozen: true)
  info = spider.get_infos!

  puts "- <#{label.colorize(:blue)}> [#{info.label.colorize(:blue)}]"
  channel.send(info)
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

# FileUtils.mkdir_p(File.join("data", "appcv", "zhinfos", site))
# FileUtils.mkdir_p(File.join("data", "appcv", "zhchaps", site))

alias Mapping = NamedTuple(bsid: String, title: String, author: String, mtime: Int64)

# TODO: skip parsing mapped files

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

skips = Set(String).new
skip_dir = File.join("data", "inits", site, "skips")
if File.exists?(skip_dir)
  files = Dir.children(skip_dir)
  skips.concat(files.map { |file| File.basename(file, ".txt") })
end

info_dir = File.join("data", "appcv", "zhinfos", site)
FileUtils.mkdir_p(File.join(info_dir))

infos.each do |info|
  next unless info

  info_file = File.join(info_dir, "#{info.bsid}.#{info.hash}.json")
  File.write(info_file, info.to_pretty_json)

  next if skips.includes?(info.bsid)

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
