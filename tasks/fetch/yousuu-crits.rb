require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

# ## Prepare proxies

require_relative "./yousuu-utils"
proxies = load_proxies

# ## Core

PAGE = (ARGV[0] || "1").to_i
puts "PAGE: #{PAGE}"
exit if PAGE < 1

OUTDATED = 3600 * 24 * 7
def file_outdated?(file)
  return true unless File.exists?(file)
  # data = File.read(file)

  # outdated = OUTDATED
  # outdated *= 4 if data.include?("未找到该图书")

  Time.now.to_i - File.mtime(file).to_i > OUTDATED
end


ROOT_DIR = "data/.inits/txt-inp/yousuu/reviews/"
OUT_FILE = "#{ROOT_DIR}/page#{PAGE}/%i.json"
REVIEW_URL = "https://www.yousuu.com/api/book/%i/comment?t=%i&page=#{PAGE}"


def fetch_data(bsid, proxy)
  file = OUT_FILE % bsid
  return :skip unless file_outdated?(file)

  url = REVIEW_URL % [bsid, unix_ms]
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

# Prepare bsids

bsids = []

Dir.glob("data/book_infos/*.json").each do |file|
  json = JSON.parse(File.read(file))

  bsid = json["yousuu"]
  next if bsid.empty?
  next unless file_outdated?(OUT_FILE % bsid)

  bsids << bsid
end

puts "Input: #{bsids.size}".yellow

# ## Crawling!

step = 1
until proxies.empty? || bsids.empty?
  puts "[LOOP:#{step}]: \
        bsids: #{bsids.size}, \
        proxies: #{proxies.size}".cyan

  failure_bsids = []
  working_proxies = []

  limit = proxies.size
  limit = bsids.size if limit > bsids.size

  Parallel.each(1..limit, in_threads: 20) do |idx|
    proxy = proxies.pop
    bsid = bsids.pop

    res = fetch_data(bsid, proxy)
    message = "- [#{idx}/#{limit}]: #{res}! bsid: [#{bsid}], proxy: [#{proxy}]"

    case res
    when :skip
      working_proxies << proxy
    when :done
      working_proxies << proxy
      puts message.green unless VERBOSE
    when :error
      failure_bsids << bsid
      puts message.red unless VERBOSE
    end
  end

  step += 1
  bsids.concat(failure_bsids).uniq!
  proxies.concat(working_proxies).uniq!
end
