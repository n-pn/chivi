require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

# ## Core

ROOT_DIR = "data/txt-inp/yousuu/serials/"
OUT_FILE = "#{ROOT_DIR}/%i.json"
BOOK_URL = "https://www.yousuu.com/api/book/%i?t=%i"

def out_file(book_id)
  OUT_FILE % book_id
end

def to_unix_ms(time = Time.now)
  (time.to_f * 1000).round
end

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

def fetch_meta(book_id, proxy, verbose = false)
    begin
      url = BOOK_URL % [book_id, to_unix_ms(Time.now)]
      puts "HIT: [#{url}], proxy: [#{proxy}]".blue if verbose

      body = URI.open(url, proxy: proxy, read_timeout: 10, "User-Agent" => USER_AGENT) { |f| f.read }
      raise "Malformed!" unless body.include?("{\"success\":true,") || body.include?("未找到该图书")

      puts "- proxy [#{proxy}] worked!".green if verbose
      File.write out_file(book_id), body

      {status: :ok, proxy: proxy, book_id: book_id}
    rescue => err
      puts "- proxy [#{proxy}] not working, reason: #{err}".red if verbose

      {status: :err, proxy: proxy, book_id: book_id}
    end
end

# ## Prepare proxies


def load_proxies(file)
  return [] unless File.exists?(file)

  proxies = File.read(file).split("\n").map(&:strip).reject(&:empty?).map do |line|
    line.include?("http") ? line : "http://#{line}"
  end

  puts "- loaded #{proxies.size} proxies from [#{file}]".blue
  proxies.uniq
end

OUTDATED = 3600 * 24 * 5 # 5 days
def file_outdated?(file, span = OUTDATED)
  return true unless File.exists?(file)
  mtime = File.mtime(file).to_i
  Time.now.to_i - mtime > span
end

PROXY_TIME = Time.new.to_i / (3600 * 4)
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

# # Prepare serials

TOTAL   = 182000 # max book_id
VERBOSE = ARGV.include?("verbose")

puts "Check for outdated entries...".blue

fetched = Dir.glob("#{ROOT_DIR}/*.json").reject { |file| file_outdated?(file) }
existed = Set.new fetched.map { |x| File.basename(x, ".json").to_i }
serials = (1..TOTAL).reject { |x| existed.include?(x) }

if ARGV.include?("shuffle")
  puts "SHUFFLE INPUT!".yellow
  serials = serials.shuffle
elsif ARGV.include?("reverse")
  puts "REVERSE INPUT!".yellow
  serials = serials.reverse
end

# ## Crawling!

step = 1
until proxies.empty? || serials.empty?
  puts "[LOOP:#{step}]: serials: #{serials.size}, proxies: #{proxies.size}".cyan

  working = []
  failure = []

  Parallel.each_with_index(proxies.take(serials.size), in_threads: 20) do |proxy, idx|
    book_id = serials.pop

    res = fetch_meta(book_id, proxy, VERBOSE)

    if res[:status] == :ok
      working << res[:proxy]

      puts "- [#{idx + 1}/#{proxies.size}] ok! (book_id: #{res[:book_id]}, proxy: #{res[:proxy]})".green
      File.open(PROXY_FILE, "a") { |f| f.puts proxy.sub("http://", "") }
    else
      puts "- [#{idx + 1}/#{proxies.size}] error! (book_id: #{res[:book_id]}, proxy: #{res[:proxy]})".red
      failure << res[:book_id]
    end
  end

  step += 1
  proxies = working
  serials.concat failure
end
