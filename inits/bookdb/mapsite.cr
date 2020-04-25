require "json"
require "time"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/spider/cr_info.cr"

REQUIRE_HTML = ARGV.includes?("require_html")

def fetch_info(channel, site, bsid, label = "1/1") : Void
  spider = Spider::CrInfo.new(site, bsid, cache: true, span: 6.months)
  info = spider.extract_info!

  puts "- <#{label.colorize(:blue)}> [#{site}/#{bsid.colorize(:blue)}] {#{info.title.colorize(:blue)}}"
  channel.send({bsid, info.title, info.author})
rescue err
  puts "- <#{label.colorize(:red)}> [#{site}/#{bsid.colorize(:red)}] \
          ERROR: <#{err.class}> #{err.colorize(:red)}"
  channel.send({bsid, "", ""})
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

puts "- CONFIG: { \
  site: #{site.colorize(:yellow)}, \
  from: #{from.colorize(:yellow)}, \
  upto: #{upto.colorize(:yellow)}, \
  worker: #{worker.colorize(:yellow)} \
}"

FileUtils.mkdir_p "data/txt-tmp/sitemap"

out_file = "data/txt-tmp/sitemap/#{site}.txt"

alias Result = Tuple(String, String, String)

sitemap = Array(Result).new
indexed = Set(String).new

if File.exists?(out_file)
  lines = File.read_lines(out_file)
  lines.each do |line|
    next if line.empty?
    bsid, title, author = line.split("--", 3)
    sitemap << {bsid, title, author}
    indexed << bsid
  end
end

queue = [] of String
from.upto(upto) do |idx|
  book_id = idx.to_s
  queue << book_id unless indexed.includes?(book_id)
end

puts "- QUEUE: #{queue.size.colorize(:yellow)} entries"
exit 0 if queue.empty?

worker = queue.size if worker > queue.size
channel = Channel(Result).new(worker)

queue.each_with_index do |book_id, idx|
  sitemap << channel.receive unless idx < worker

  spawn do
    fetch_info(channel, site, book_id, "#{idx + 1}/#{queue.size}")
  end
end

worker.times { sitemap << channel.receive }

File.write(out_file, sitemap.map(&.join("--")).join("\n"))
