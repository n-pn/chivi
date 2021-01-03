require "mime"
require "colorize"
require "file_utils"

require "../../src/filedb/stores/*"
require "../../src/shared/http_utils"

class CV::Seed::FetchCovers
  def initialize(@skip_empty = true)
  end

  def fetch_yousuu!
    dir = "_db/_seeds/yousuu/covers"
    ::FileUtils.mkdir_p(dir)

    queue = {} of String => String

    sbids = ValueMap.new("_db/nvdata/nvinfos/yousuu.tsv", mode: 2).vals
    covers = ValueMap.new("_db/_seeds/yousuu/bcover.tsv", mode: 2)
    sbids.each do |vals|
      sbid = vals.first
      out_file = "#{dir}/#{sbid}.jpg"
      next if valid_file?(out_file)

      next unless image_url = covers.fval(sbid)
      next if image_url.empty?
      queue[image_url] = out_file
    end

    fetch!(queue)
  end

  def fetch!(queue : Hash(String, String), limit = 8) : Nil
    puts queue.size

    limit = queue.size if limit > queue.size
    channel = Channel(Nil).new(limit)

    queue.each_with_index do |(link, file), idx|
      channel.receive if idx > limit

      spawn do
        HttpUtils.save_file(link, file)
      rescue err
        puts err
        FileUtils.touch(file)
      ensure
        channel.send(nil)
      end
    end

    limit.times { channel.receive }
  end

  def valid_file?(file : String)
    return false unless File.exists?(file)
    @skip_empty || File.size(file) > 0
  end
end

worker = CV::Seed::FetchCovers.new(ARGV.includes?("skip_empty"))
worker.fetch_yousuu!
# worker.fetch_chseed!
