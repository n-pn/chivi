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
puts "-- [ PAGE: #{PAGE} ] --"
exit if PAGE < 1

EXPIRY = 3600 * 24 * 5
def file_outdated?(file)
  return true unless File.exists?(file)
  expiry = EXPIRY

  data = File.read(file)
  expiry *= 4 if data.include?("未找到该图书")

  File.mtime(file).to_i < Time.now.to_i - expiry
end

ROOT_DIR = "var/appcv/.cache/yousuu/reviews"
OUT_FILE = "#{ROOT_DIR}/%i-#{PAGE}.json"
REVIEW_URL = "https://www.yousuu.com/api/book/%i/comment?t=%i&page=#{PAGE}"

def fetch_data(ybid, proxy)
  file = OUT_FILE % ybid
  return :skip unless file_outdated?(file)

  url = REVIEW_URL % [ybid, unix_ms]
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


def load_ybids(page = 1)
  files = Dir.glob("var/appcv/book_miscs/*.json")
  files.inject([]) do |memo, file|
    json = JSON.parse(File.read(file))
    link = json["yousuu_link"]

    unless link.empty?
      ybid = File.basename(link)
      # TODO: check review total
      memo << ybid if file_outdated?(OUT_FILE % ybid)
    end

    memo
  end
end

# Prepare ybids

ybids = load_ybids()
puts "Input: #{ybids.size}".yellow

# ## Crawling!

step = 1
until proxies.empty? || ybids.empty?
  puts "- <#{step}> ybids: #{ybids.size}, proxies: #{proxies.size}".cyan

  failure_ybids = []
  working_proxies = []

  limit = proxies.size
  limit = ybids.size if limit > ybids.size

  Parallel.each(1..limit, in_threads: 20) do |idx|
    ybid = ybids.pop
    proxy = proxies.pop

    result = fetch_data(ybid, proxy)
    message = "- [#{idx}/#{limit}]: #{result}! ybid: [#{ybid}], proxy: [#{proxy}]"

    case result

    when :skip
      working_proxies << proxy
    when :error
      failure_ybids << ybid
      puts message.red unless VERBOSE
    when :success
      working_proxies << proxy
      puts message.cyan unless VERBOSE
    end
  end

  step += 1
  ybids.concat(failure_ybids).uniq!
  proxies.concat(working_proxies).uniq!
end
