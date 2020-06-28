require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

# # Prepare proxies

require_relative "./crawl-utils"
proxies = load_proxies

# ## Core

ROOT_DIR = "data/.inits/books/yousuu/serials"
OUT_FILE = "#{ROOT_DIR}/%i.json"
BOOK_URL = "https://www.yousuu.com/api/book/%i?t=%i"

OUTDATED = 3600 * 24 * 3 # 3 days
def get_outdated_by_status(data)
  json = JSON.parse(data)

  status = json["data"]["bookInfo"]["status"] || 0
  outdated = OUTDATED * (status + 1) # bump to 6 days or 9 days

  score = json["data"]["bookInfo"]["score"] || 0
  outdated *= 3 if score == 0 # bump to 9, 12 or 18 days

  outdated
end

def info_outdated?(file)
  return true unless File.exists?(file)

  data = File.read(file)
  if data.include?("未找到该图书")
    outdated = OUTDATED * 5 # 15 days
  else
    outdated = get_outdated_by_status(data)
  end

  Time.now.to_i - File.mtime(file).to_i > outdated
end

def fetch_meta(serial, proxy)
  file = OUT_FILE % serial
  return :skip unless info_outdated?(file)

  url = BOOK_URL % [serial, unix_ms]
  body = fetch_url(url, proxy)

  raise "Malformed!" unless body.include?("success") || body.include?("未找到该图书")

  File.write(file, body)
  save_proxy(proxy)

  puts "- proxy [#{proxy}] worked!".green if VERBOSE
  :done
rescue => err
  puts "- proxy [#{proxy}] not working, reason: #{err}".red if VERBOSE
  :error
end

# # Prepare serials

TOTAL = 212200 # max serial
serials = (1..TOTAL).to_a

if ARGV.include?("shuffle")
  puts "SHUFFLE INPUT!".yellow
  serials.shuffle!
elsif ARGV.include?("reverse")
  puts "REVERSE INPUT!".yellow
  serials.reverse!
end

# # Crawling!

step = 1
until proxies.empty? || serials.empty?
  puts "[LOOP:#{step}]: \
        serials: #{serials.size}, \
        proxies: #{proxies.size}".cyan

  working = []
  failure = []

  total = proxies.size
  total = serials.size if total > serials.size

  Parallel.each_with_index(1..total, in_threads: 20) do |idx|
    proxy = proxies.pop
    serial = serials.pop

    res = fetch_meta(serial, proxy)
    message = "- [#{idx}/#{total}]: #{res}! serial: [#{serial}], proxy: [#{proxy}]"

    case res
    when :skip
      working << proxy
    when :done
      working << proxy
      puts message.green unless VERBOSE
    when :error
      failure << serial
      puts message.red unless VERBOSE
    end
  end

  step += 1
  proxies.concat(working).uniq!
  serials.concat(failure).uniq!
end
