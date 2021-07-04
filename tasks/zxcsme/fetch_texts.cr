require "file_utils"
require "compress/gzip"
require "myhtml"

require "../../src/cutil/http_utils"

class CV::Seeds::ZxcsText
  DLPG_DIR = File.join("_db/.cache/zxcs_me/dlpgs")
  RARS_DIR = File.join("_db/.keeps/zxcs_me/rars")

  FileUtils.mkdir_p(DLPG_DIR)
  FileUtils.mkdir_p(RARS_DIR)

  def fetch!(from = 1, upto = 12092) : Nil
    queue = (from..upto).to_a.reverse
    queue.each_with_index(1) do |snvid, idx|
      rar_file = "#{RARS_DIR}/#{snvid}.rar"
      next if File.exists?(rar_file) && File.size(rar_file) > 1000

      urls = get_rar_urls(snvid, label: "#{idx}/#{queue.size}")
      urls.reverse_each { |url| save_rar(url, rar_file) }
    rescue err
      puts err.colorize.red
    end
  end

  TTL = Time.utc - 7.days # invalid cached html in 7 days

  def get_rar_urls(snvid : Int32, label = "1/1") : Array(String)
    out_file = File.join(DLPG_DIR, "#{snvid}.html.gz")
    dlpg_url = "http://www.zxcs.me/download.php?id=#{snvid}"

    html = HttpUtils.load_html(dlpg_url, out_file, ttl: TTL, label: label)

    doc = Myhtml::Parser.new(html)
    doc.css(".downfile > a").to_a.map do |node|
      node.attributes["href"].not_nil!
    end
  end

  def save_rar(rar_link : String, out_file : String) : Nil
    # skipping downloaded files, unless they are 404 pages
    return if File.exists?(out_file) && File.size(out_file) > 1000

    HTTP::Client.get(rar_link) { |res| File.write(out_file, res.body_io) }
    puts "- Saving [#{File.basename(rar_link).colorize.green}] \
            to [#{File.basename(out_file).colorize.green}], \
            file size: #{File.size(out_file)} bytes"
  end
end

worker = CV::Seeds::ZxcsText.new
worker.fetch!(from: 1, upto: 12900)
