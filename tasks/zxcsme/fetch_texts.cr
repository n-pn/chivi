require "file_utils"
require "compress/gzip"
require "myhtml"

require "../../src/_util/http_util"

class CV::Seeds::ZxcsText
  DLPG_DIR = File.join("_db/.cache/zxcs_me/dlpgs")
  RARS_DIR = File.join("_db/.keeps/zxcs_me/_rars")

  FileUtils.mkdir_p(DLPG_DIR)
  FileUtils.mkdir_p(RARS_DIR)

  def fetch!(max = 14000, min = 1) : Nil
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

  TTL = Time.utc - 7.days # invalid cached html in 7 days

  def get_rar_urls(snvid : Int32, lbl = "1/1") : Array(String)
    out_file = File.join(DLPG_DIR, "#{snvid}.html.gz")
    dlpg_url = "http://www.zxcs.me/download.php?id=#{snvid}"

    html = HttpUtil.load_html(dlpg_url, out_file, ttl: TTL, lbl: lbl)

    doc = Myhtml::Parser.new(html)
    doc.css(".downfile > a").to_a.map do |node|
      node.attributes["href"].not_nil!
    end
  end

  def download_rar!(rar_link : String, out_file : String) : Nil
    # skipping downloaded files, unless they are 404 pages
    return if File.exists?(out_file) && File.size(out_file) >= 50000

    HTTP::Client.get(rar_link) { |res| File.write(out_file, res.body_io) }
    puts "- Saving [#{File.basename(rar_link).colorize.green}] \
            to [#{File.basename(out_file).colorize.green}], \
            file size: #{File.size(out_file)} bytes"
  rescue err
    puts "- [#{File.basename(out_file)}] <#{rar_link}>: #{err}".colorize.red
  end
end

worker = CV::Seeds::ZxcsText.new
worker.fetch!(max: 13600, min: 12000)
