require "file_utils"
require "compress/gzip"
require "../../../src/utils/http_utils"

INFO_DIR = File.join("_db/.cache/zxcs_me/infos")
DLPG_DIR = File.join("_db/.cache/zxcs_me/dlpgs")

FileUtils.mkdir_p(INFO_DIR)
FileUtils.mkdir_p(DLPG_DIR)

def crawl!(from = 1, upto = 12092, type = "infos")
  rdir = type == "infos" ? INFO_DIR : DLPG_DIR

  queue = (from..upto).to_a
  queue.each_with_index(1) do |snvid, idx|
    file = File.join(rdir, "#{snvid}.html.gz")
    next if File.exists?(file)

    link =
      if type == "infos"
        "http://www.zxcs.me/post/#{snvid}"
      else
        "http://www.zxcs.me/download.php?id=#{snvid}"
      end

    File.open(file, "w") do |io|
      html = CV::HttpUtils.get_html(link, label: "#{idx}/#{queue.size}")
      Compress::Gzip::Writer.open(io, &.print(html))
    end

    sleep Random.rand(500).milliseconds
  rescue err
    puts err.colorize.red
  end
end

crawl!(1, 12602, "dlpgs")
