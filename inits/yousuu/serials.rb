require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"


# # Prepare proxies

require_relative "./_utils"
proxies = load_proxies

# ## Core

ROOT_DIR = "data/txt-inp/yousuu/serials"
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
    outdated = OUTDATED * 10 # 30 days
  else
    outdated = get_outdated_by_status(data)
  end

  Time.now.to_i - File.mtime(file).to_i > outdated
end

def fetch_meta(book_id, proxy)
  file = OUT_FILE % book_id
  return :skip unless info_outdated?(file)

  url = BOOK_URL % [book_id, unix_ms]
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

# # Prepare book_ids

TOTAL = 212100 # max book_id
book_ids = (1..TOTAL).to_a

if ARGV.include?("shuffle")
  puts "SHUFFLE INPUT!".yellow
  book_ids.shuffle!
elsif ARGV.include?("reverse")
  puts "REVERSE INPUT!".yellow
  book_ids.reverse!
end

# # Crawling!

step = 1
until proxies.empty? || book_ids.empty?
  puts "[LOOP:#{step}]: \
        book_ids: #{book_ids.size}, \
        proxies: #{proxies.size}".cyan

  working = []
  failure = []

  Parallel.each_with_index(proxies.take(book_ids.size), in_threads: 20) do |proxy, idx|
    book_id = book_ids.pop

    res = fetch_meta(book_id, proxy)
    message = "- [#{idx + 1}/#{proxies.size}]: #{res}! book_id: [#{book_id}], proxy: [#{proxy}]"

    case res
    when :skip
      working << proxy
    when :done
      working << proxy
      puts message.green unless VERBOSE
    when :error
      failure << book_id
      puts message.red unless VERBOSE
    end
  end

  step += 1
  proxies.concat(working).uniq!
  book_ids.concat(failure).uniq!
end
