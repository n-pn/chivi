require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

# ## Prepare proxies

require_relative "./crawl-utils"
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


ROOT_DIR = "assets/.inits/books/yousuu/reviews/"
OUT_FILE = "#{ROOT_DIR}/page#{PAGE}/%i.json"
REVIEW_URL = "https://www.yousuu.com/api/book/%i/comment?t=%i&page=#{PAGE}"


def fetch_data(serial, proxy)
  file = OUT_FILE % serial
  return :skip unless file_outdated?(file)

  url = REVIEW_URL % [serial, unix_ms]
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

# Prepare serials

serials = []

Dir.glob("data/vp_infos/*.json").each do |file|
  json = JSON.parse(File.read(file))

  serial = json["yousuu"]
  next if serial.empty?
  next unless file_outdated?(OUT_FILE % serial)

  serials << serial
end

puts "Input: #{serials.size}".yellow

# ## Crawling!

step = 1
until proxies.empty? || serials.empty?
  puts "[LOOP:#{step}]: \
        serials: #{serials.size}, \
        proxies: #{proxies.size}".cyan

  failure_serials = []
  working_proxies = []

  limit = proxies.size
  limit = serials.size if limit > serials.size

  Parallel.each(1..limit, in_threads: 20) do |idx|
    proxy = proxies.pop
    serial = serials.pop

    res = fetch_data(serial, proxy)
    message = "- [#{idx}/#{limit}]: #{res}! serial: [#{serial}], proxy: [#{proxy}]"

    case res
    when :skip
      working_proxies << proxy
    when :done
      working_proxies << proxy
      puts message.green unless VERBOSE
    when :error
      failure_serials << serial
      puts message.red unless VERBOSE
    end
  end

  step += 1
  serials.concat(failure_serials).uniq!
  proxies.concat(working_proxies).uniq!
end
