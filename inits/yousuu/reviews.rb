require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

VERBOSE = ARGV.include?("verbose")

# ## Prepare proxies

require_relative "./_utils"
proxies = load_proxies

# ## Core

PAGE = (ARGV[0] || "1").to_i
puts "PAGE: #{PAGE}"
exit if PAGE < 1

ROOT_DIR = "data/txt-inp/yousuu/reviews/"
OUT_FILE = "#{ROOT_DIR}/page#{PAGE}/%i.json"
REVIEW_URL = "https://www.yousuu.com/api/book/%i/comment?t=%i&page=#{PAGE}"

OUTDATED = 3600 * 24 * 3 # 3 days
def file_outdated?(file)
  return true unless File.exists?(file)
  data = File.read(file)

  outdated = OUTDATED
  outdated *= 10 if data.include?("未找到该图书")

  Time.now.to_i - File.mtime(file).to_i > outdated
end

def fetch_data(book_id, proxy)
  file = OUT_FILE % book_id
  return :skip unless file_outdated?(file)

  url = REVIEW_URL % [book_id, unix_ms]
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


# Prepare book_ids

serials = JSON.parse File.read("data/txt-tmp/serials.json")
book_ids = serials.map{|x| x["yousuu_bids"]}.flatten

puts "Input: #{book_ids.size}".yellow

# ## Crawling!

step = 1
until proxies.empty? || book_ids.empty?
  puts "[LOOP:#{step}]: \
        book_ids: #{book_ids.size}, \
        proxies: #{proxies.size}".cyan

  working = []
  failure = []

  Parallel.each_with_index(proxies.take(book_ids.size), in_threads: 20) do |proxy, idx|
    book_id = book_ids.pop

    res = fetch_data(book_id, proxy)
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
