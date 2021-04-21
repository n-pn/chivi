require "file_utils"
require "compress/gzip"
require "../../src/utils/http_utils"

require "./_seeding"

class CV::MapZxcsMe
  INP_DIR = "_db/.cache/zxcs_me/infos"
  OUT_DIR = "_db/_seeds/zxcs_me"

  ::FileUtils.mkdir_p(INP_DIR)
  ::FileUtils.mkdir_p(OUT_DIR)

  getter meta = Seeding.new("zxcs_me")
  getter snvids : Array(String)

  def initialize
    @snvids = Dir.glob("_db/ch_infos/origs/zxcs_me/*.tsv").map do |file|
      File.basename(file, ".tsv")
    end

    @snvids.sort_by!(&.to_i)
  end

  def prep!
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")
      next if File.exists?(file)

      link = "http://www.zxcs.me/post/#{snvid}"

      File.open(file, "w") do |io|
        html = HttpUtils.get_html(link, label: "#{idx}/#{@snvids.size}")
        Compress::Gzip::Writer.open(io, &.print(html))
      end

      sleep Random.rand(500).milliseconds
    rescue err
      puts err.colorize.red
    end
  end
end

worker = CV::MapZxcsMe.new
worker.prep!
