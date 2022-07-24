require "file_utils"
require "http/client"

require "lexbor"
require "../../src/_util/http_util"

class CV::Seeds::ZxcsText
  DLPG_DIR = File.join("var/books/.html/zxcs_me/dlpgs")
  RARS_DIR = File.join("var/chaps/.zips/zxcs_me")

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

  def get_rar_urls(snvid : Int32, lbl = "1/1") : Array(String)
    out_file = File.join(DLPG_DIR, "#{snvid}.html.gz")
    dlpg_url = "http://www.zxcs.me/download.php?id=#{snvid}"

    html = HttpUtil.cache(out_file, dlpg_url, ttl: 7.days, lbl: lbl)

    doc = Lexbor::Parser.new(html)
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

max = ARGV.fetch(0, "14000").to_i
min = ARGV.fetch(1, "10000").to_i
worker = CV::Seeds::ZxcsText.new
worker.fetch!(max: max, min: min)
