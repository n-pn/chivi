require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

VERBOSE = ARGV.include?("verbose")

# # Prepare proxies

def load_proxies(file)
  return [] unless File.exists?(file)

  proxies = File.read(file).split("\n").map(&:strip).reject(&:empty?).uniq
  puts "- loaded #{proxies.size} proxies from [#{file}]".blue

  proxies
end

PROXY_TIME = Time.new.to_i / (3600 * 6)
PROXY_FILE = "data/txt-inp/yousuu/proxies/working/#{PROXY_TIME}.txt"
proxies = load_proxies(PROXY_FILE)

if proxies.size < 200
  workings = Dir.glob("data/txt-inp/yousuu/proxies/working/*.txt").reject{|x| x == PROXY_FILE}
  if workings.size > 0
    puts "Load previous working proxies!".yellow
    prev_file = workings.sort.last
    proxies.concat(load_proxies(prev_file))
  end
end

if proxies.size < 200 || ARGV.include?("proxy")
  puts "Load new proxies!".yellow
  Dir.glob("data/txt-inp/yousuu/proxies/*.txt").each { |file| proxies.concat load_proxies(file) }
end

proxies.uniq!
# proxies = proxies.shuffle

# ## Core

ROOT_DIR = "data/txt-inp/yousuu/serials/"
OUT_FILE = "#{ROOT_DIR}/%i.json"
BOOK_URL = "https://www.yousuu.com/api/book/%i?t=%i"

OUTDATED = 3600 * 24 * 3 # 3 days
def outdated?(file)
  return true unless File.exists?(file)

  data = File.read(file)
  return false if data.include?("未找到该图书")

  json = JSON.parse(data)

  status = json["data"]["bookInfo"]["status"] || 0
  outdated = OUTDATED * (status + 1) # bump to 6 days or 9 days

  score = json["data"]["bookInfo"]["score"] || 0
  outdated *= 3 if score == 0 # bump to 9, 12 or 18 days

  mtime = File.mtime(file).to_i
  Time.now.to_i - mtime > outdated
end

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

def fetch_meta(book_id, proxy)
  file = OUT_FILE % book_id
  return :skip unless outdated?(file)

  url = BOOK_URL % [book_id, (Time.now.to_f * 1000).round]
  puts "HIT: [#{url}], proxy: [#{proxy}]".blue if VERBOSE

  body = URI.open(url, proxy: "http://#{proxy}", read_timeout: 10, "User-Agent" => USER_AGENT) { |f| f.read }
  raise "Malformed!" unless body.include?("{\"success\":true,") || body.include?("未找到该图书")

  File.write(file, body)
  File.open(PROXY_FILE, "a") { |f| f.puts proxy }

  puts "- proxy [#{proxy}] worked!".green if VERBOSE
  :done
rescue => err
  puts "- proxy [#{proxy}] not working, reason: #{err}".red if VERBOSE
  :error
end

# # Prepare serials

TOTAL = 212000 # max book_id
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
  puts "[LOOP:#{step}]: serials: #{serials.size}, proxies: #{proxies.size}".cyan
  step += 1

  working = []
  failure = []

  Parallel.each_with_index(proxies.take(serials.size), in_threads: 20) do |proxy, idx|
    book_id = serials.pop

    res = fetch_meta(book_id, proxy)
    message = "- [#{idx + 1}/#{proxies.size}]: #{res}! (book_id: [#{book_id}], proxy: [#{proxy}])"

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

  proxies.concat(working).uniq!
  serials.concat(failure).uniq!
end
