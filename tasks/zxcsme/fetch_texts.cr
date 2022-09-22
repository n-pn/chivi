require "file_utils"
require "http/client"

require "lexbor"
require "../../src/_util/http_util"

module CV::ZxcsmeTextFetch
  extend self

  HTML_DIR = "var/seeds/zxcs_me/.html"
  RARS_DIR = "var/seeds/zxcs_me/_rars"

  FileUtils.mkdir_p(HTML_DIR)
  FileUtils.mkdir_p(RARS_DIR)

  def fetch_rars!(max = 14000, min = 1) : Nil
    queue = (min..max).to_a.reverse
    queue.each_with_index(1) do |snvid, idx|
      rar_file = "#{RARS_DIR}/#{snvid}.rar"
      next if File.exists?(rar_file) && File.size(rar_file) > 1000

      urls = get_rar_urls(snvid, lbl: "#{idx}/#{queue.size}")
      urls.each { |url| download_rar!(url, rar_file) }
    rescue err
      puts "- [#{snvid}]: #{err}".colorize.red
    end
  end

  def get_rar_urls(snvid : Int32, lbl = "1/1") : Array(String)
    out_file = File.join(HTML_DIR, "#{snvid}-dl.html.gz")
    dlpg_url = "http://www.zxcs.me/download.php?id=#{snvid}"
    html = HttpUtil.cache(out_file, dlpg_url, ttl: 7.days, lbl: lbl)

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
    return if downloaded?(out_file)

    HTTP::Client.get(rar_link) { |res| File.write(out_file, res.body_io) }

    puts "- Saving [#{File.basename(rar_link).colorize.green}] \
            to [#{File.basename(out_file).colorize.green}], \
            file size: #{File.size(out_file)} bytes"
  rescue err
    puts "- [#{File.basename(out_file)}] <#{rar_link}>: #{err}".colorize.red
  end

  def run!(argv = ARGV)
    max = argv.fetch(0, "14500").to_i
    min = argv.fetch(1, "308").to_i

    fetch_rars!(max: max, min: min)
  end

  run!
end
