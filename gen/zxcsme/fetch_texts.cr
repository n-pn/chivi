require "http/client"
require "lexbor"

require "../../../src/_util/http_util"

HTML_DIR = "var/seeds/zxcs.me/.html"
RARS_DIR = "var/seeds/zxcs.me/_rars"

Dir.mkdir_p(HTML_DIR)
Dir.mkdir_p(RARS_DIR)

def get_zip_url(sb_id : Int32, lbl = "1/1") : String?
  out_path = File.join(HTML_DIR, "#{sb_id}-dl.html.gz")
  dlpg_url = "http://www.zxcs.info/download2.php?id=#{sb_id}"
  puts "- <#{lbl}> HIT: #{dlpg_url}".colorize.magenta

  html = HttpUtil.cache(file: out_path, link: dlpg_url, ttl: 15.days)
  return unless node = Lexbor::Parser.new(html).css(".downfile > a").last?

  node.attributes["href"]
end

VALID_FILE_SIZE = 5000

def downloaded?(out_path : String)
  return false unless File.exists?(out_path)
  File.size(out_path) >= VALID_FILE_SIZE
end

def download_zip_file!(zip_link : String, out_file : String) : Nil
  # skipping downloaded files, unless they are 404 pages
  # return if downloaded?(out_file)

  puts "- Fetching: #{zip_link.colorize.green}"

  HTTP::Client.get(zip_link) do |res|
    return unless res.status.success?
    File.write(out_file, res.body_io)
  end

  puts "- Saved [#{File.basename(zip_link).colorize.green}] \
            to [#{File.basename(out_file).colorize.green}], \
            file size: #{File.size(out_file).humanize}B"
rescue err
  puts "- [#{File.basename(out_file)}] <#{zip_link}>: #{err}".colorize.red
end

def still_fresh?(zip_file : String)
  return false unless info = File.info?(zip_file)
  info.modification_time > Time.utc - 15.days
end

# run!

# map_html = File.read("#{HTML_DIR}/../map.html")
# sb_ids = map_html.scan(/\/post\/(\d+)/).map(&.[1].to_i)

sb_ids = 14930.downto(1).to_a

sb_ids.each_with_index(1) do |sb_id, idx|
  zip_file = "#{RARS_DIR}/#{sb_id}.zip"
  next if still_fresh?(zip_file)

  next unless zip_url = get_zip_url(sb_id, "#{idx}/#{sb_ids.size}")
  next if zip_url.ends_with?(".rar")

  download_zip_file!(zip_url, zip_file)
rescue ex
  puts ex
end
