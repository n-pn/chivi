require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

ROOT_DIR = "var/appcv/.cache/yousuu/serials"
OUT_FILE = "#{ROOT_DIR}/%i.json"
BOOK_URL = "https://www.yousuu.com/api/book/%i?t=%i"

EXPIRY = 3600 * 24 * 3 # 3 days

def get_expiry_by_status(data)
  json = JSON.parse(data)

  status = json["data"]["bookInfo"]["status"] || 0
  expiry = EXPIRY * (status + 1) # bump to 6 days or 9 days

  score = json["data"]["bookInfo"]["score"] || 0
  expiry *= 3 if score == 0 # bump to 9, 12 or 18 days

  expiry
end

def info_outdated?(file)
  return true unless File.exists?(file)

  data = File.read(file)
  if data.include?("未找到该图书")
    expiry = OUTDATED * 5 # 15 days
  else
    expiry = get_expiry_by_status(data)
  end

  File.mtime(file).to_i < Time.now.to_i - expiry
end

def fetch_meta(ysid, proxy)
  file = OUT_FILE % ysid
  return :skip unless info_outdated?(file)

  url = BOOK_URL % [ysid, unix_ms]
  body = fetch_url(url, proxy)

  raise "Malformed!" unless body.include?("success") || body.include?("未找到该图书")

  File.write(file, body)
  save_proxy(proxy)

  puts "- proxy [#{proxy}] worked!".green if VERBOSE
  :success
rescue => err
  puts "- proxy [#{proxy}] not working, reason: #{err}".red if VERBOSE
  :error
end

# Prepare data

require_relative "./crawl-utils"
proxies = load_proxies

TOTAL = 212500 # max ysid
ysids = (1..TOTAL).to_a

if ARGV.include?("shuffle")
  puts "SHUFFLE INPUT!".yellow
  ysids.shuffle!
elsif ARGV.include?("reverse")
  puts "REVERSE INPUT!".yellow
  ysids.reverse!
end

# Crawling!

step = 1
until proxies.empty? || ysids.empty?
  puts "\n- <#{step}> ysids: #{ysids.size}, proxies: #{proxies.size}\n".yellow

  working = []
  failure = []

  limit = ysids.size
  limit = proxies.size if limit > proxies.size

  Parallel.each_with_index(1..limit, in_threads: 20) do |idx|
    ysid = ysids.pop
    proxy = proxies.pop

    status = fetch_meta(ysid, proxy)
    message = "- [#{idx}/#{limit}]: #{status}! ysid: [#{ysid}], proxy: [#{proxy}]"

    case status
    when :skip
      working << proxy
    when :error
      failure << ysid
      puts message.red unless VERBOSE
    when :success
      working << proxy
      puts message.green unless VERBOSE
    end
  end

  step += 1
  ysids.concat(failure).uniq!
  proxies.concat(working).uniq!
end
