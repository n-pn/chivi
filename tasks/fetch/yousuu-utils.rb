def read_proxy_file(file)
  return [] unless File.exists?(file)

  proxies = File.read(file).split("\n").map(&:strip).reject(&:empty?).uniq
  puts "- loaded #{proxies.size} proxies from [#{file}]".blue

  proxies
end

PROXY_DIR = "data/txt-inp/yousuu/proxies"

PROXY_TIME = Time.new.to_i / (3600 * 6)
PROXY_FILE = "#{PROXY_DIR}/working/#{PROXY_TIME}.txt"

def load_proxies
  proxies = read_proxy_file(PROXY_FILE)

  if proxies.size < 200
    workings = Dir.glob("#{PROXY_DIR}/working/*.txt").reject{|x| x == PROXY_FILE}
    if workings.size > 0
      puts "Load previous working proxies!".yellow
      prev_file = workings.sort.last
      proxies.concat(read_proxy_file(prev_file)).uniq!
    end
  end

  if proxies.size < 200 || ARGV.include?("proxy")
    puts "Load new proxies!".yellow
    Dir.glob("#{PROXY_DIR}/*.txt").each do |file|
      proxies.concat(read_proxy_file(file)).uniq!
    end
  end

  proxies
end

def save_proxy(proxy)
  File.open(PROXY_FILE, "a") { |f| f.puts proxy }
end

VERBOSE = ARGV.include?("verbose")

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

def fetch_url(url, proxy)
  puts "HIT: [#{url}], proxy: [#{proxy}]".blue if VERBOSE

  URI.open(url, proxy: "http://#{proxy}", read_timeout: 10, "User-Agent" => USER_AGENT) { |f| f.read }
end

def unix_ms(time = Time.now)
  (time.to_f * 1000).round
end
