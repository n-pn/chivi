require "file_utils"
require "compress/gzip"
require "../../../src/utils/http_utils"

INFO_DIR = File.join("_db/.cache/zxcs_me/infos")
FileUtils.mkdir_p(INFO_DIR)

class CV::SeedInfo::ZxcsMe
  def prep!(from = 1, upto = 12092)
    queue = (from..upto).to_a
    queue.each_with_index(1) do |snvid, idx|
      file = File.join(INFO_DIR, "#{snvid}.html.gz")
      next if File.exists?(file)

      link = "http://www.zxcs.me/post/#{snvid}"

      File.open(file, "w") do |io|
        html = CV::HttpUtils.get_html(link, label: "#{idx}/#{queue.size}")
        Compress::Gzip::Writer.open(io, &.print(html))
      end

      sleep Random.rand(500).milliseconds
    rescue err
      puts err.colorize.red
    end
  end
end

worker = CV::SeedInfo::ZxcsMe.new
worker.prep!(1, 12526)
