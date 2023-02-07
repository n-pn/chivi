require "lexbor"
require "http/client"
require "../../src/_util/http_util"

HTML_DIR = "var/seeds/zxcs.me/.html"
RARS_DIR = "var/seeds/zxcs.me/_rars"

Dir.mkdir_p(HTML_DIR)
Dir.mkdir_p(RARS_DIR)

# def fetch_rars!(max = 14000, min = 1) : Nil
#   queue = (min..max).to_a.reverse
#   queue.each_with_index(1) do |s_bid, idx|
#     rar_file = "#{RARS_DIR}/#{s_bid}.rar"
#     next if File.exists?(rar_file) && File.size(rar_file) > 1000

#     urls = get_rar_urls(s_bid, lbl: "#{idx}/#{queue.size}")
#     urls.each { |url| download_rar!(url, rar_file) }
#   rescue err
#     puts "- [#{s_bid}]: #{err}".colorize.red
#   end
# end

# def run!(argv = ARGV)
#   max = argv.fetch(0, "14500").to_i
#   min = argv.fetch(1, "308").to_i

#   fetch_rars!(max: max, min: min)
# end

def get_rar_urls(s_bid : Int32, lbl = "1/1") : Array(String)
  out_file = File.join(HTML_DIR, "#{s_bid}-dl.html.gz")
  dlpg_url = "http://www.zxcs.me/download.php?id=#{s_bid}"
  puts "- <#{lbl}> HIT: #{dlpg_url}".colorize.magenta

  html = HttpUtil.cache(file: out_file, link: dlpg_url, ttl: 7.days)

  nodes = Lexbor::Parser.new(html).css(".downfile > a")
  nodes.to_a.map(&.attributes["href"].not_nil!)
end

VALID_FILE_SIZE = 5000

def downloaded?(out_file : String)
  return false unless File.exists?(out_file)
  File.size(out_file) >= VALID_FILE_SIZE
end

def download_rar!(rar_link : String, out_file : String) : Nil
  # skipping downloaded files, unless they are 404 pages
  # return if downloaded?(out_file)

  puts "- Downloading: #{rar_link}"

  HTTP::Client.get(rar_link) do |res|
    return unless res.status.success?
    File.write(out_file, res.body_io)
  end

  puts "- Saving [#{File.basename(rar_link).colorize.green}] \
            to [#{File.basename(out_file).colorize.green}], \
            file size: #{File.size(out_file).humanize}B"
rescue err
  puts "- [#{File.basename(out_file)}] <#{rar_link}>: #{err}".colorize.red
end

def still_fresh?(rar_file : String)
  return false unless info = File.info?(rar_file)
  info.modification_time < Time.utc - 1.days
end

# run!

map_html = File.read("#{HTML_DIR}/../map.html")

s_bids = map_html.scan(/http:\/\/zxcs.me\/post\/(\d+)/).map(&.[1].to_i)

s_bids.each_with_index(1) do |s_bid, idx|
  rar_file = "#{RARS_DIR}/#{s_bid}.rar"
  next if still_fresh?(rar_file)

  get_rar_urls(s_bid, "#{idx}/#{s_bids.size}").each do |url|
    download_rar!(url, rar_file)
    break if downloaded?(rar_file)
  end
end
