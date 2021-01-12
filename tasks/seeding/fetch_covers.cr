require "mime"
require "colorize"
require "file_utils"

require "../../src/filedb/stores/value_map"
require "../../src/shared/http_utils"

class CV::Seed::FetchCovers
  def fetch_yousuu!
    dir = "_db/nvdata/_covers/yousuu"
    ::FileUtils.mkdir_p(dir)

    queue = {} of String => String

    sbids = ValueMap.new("_db/nvdata/nvinfos/yousuu.tsv", mode: 2).vals
    covers = ValueMap.new("_db/_seeds/yousuu/bcover.tsv", mode: 2)
    sbids.each do |vals|
      sbid = vals.first
      out_file = "#{dir}/#{sbid}.jpg"
      next if File.exists?(out_file)

      next unless image_url = covers.fval(sbid)
      queue[image_url] = out_file unless image_url.empty?
    end

    fetch!(queue, limit: 16)
  end

  def fetch_chseed!
    input = ValueMap.new("_db/nvdata/nvinfos/chseed.tsv", mode: 2).vals

    queues = Hash(String, Hash(String, String)).new do |h, k|
      h[k] = {} of String => String
    end

    input.each do |seeds|
      seeds.each do |entry|
        seed, sbid = entry.split("/")
        next if seed == "jx_la"

        out_file = "_db/nvdata/_covers/#{seed}/#{sbid}.jpg"
        next if File.exists?(out_file)

        next unless image_url = cover_map(seed).fval(sbid)
        queues[seed][image_url] = out_file unless image_url.empty?
      end
    end

    channel = Channel(Nil).new(queues.size)

    queues.each do |seed, queue|
      limit, delayed =
        case seed
        when "shubaow" then {1, 2.seconds}
        when "duokan8" then {1, 1.seconds}
        when "zhwenpg" then {1, 500.milliseconds}
        when "paoshu8" then {2, 500.milliseconds}
        when "69shu"   then {4, 200.milliseconds}
        when "5200"    then {4, 100.milliseconds}
        else                {8, 10.milliseconds}
        end

      spawn do
        fetch!(queue, limit, delayed)
      ensure
        channel.send(nil)
      end
    end

    queues.size.times { channel.receive }
  end

  getter cache = {} of String => ValueMap

  def cover_map(seed : String)
    cache[seed] ||= ValueMap.new("_db/_seeds/#{seed}/bcover.tsv", mode: 2)
  end

  def fetch!(queue : Hash(String, String), limit = 8, delayed = 10.milliseconds)
    puts queue.size

    limit = queue.size if limit > queue.size
    channel = Channel(Nil).new(limit)

    queue.each_with_index do |(link, file), idx|
      channel.receive if idx > limit

      spawn do
        HttpUtils.save_file(link, file)
        fix_image_ext(file)
        sleep delayed
      rescue err
        puts err.colorize.red
        FileUtils.touch(file)
      ensure
        channel.send(nil)
      end
    end

    limit.times { channel.receive }
  end

  def fix_image_ext(inp_file : String)
    return if File.size(inp_file) == 0

    return unless type = image_type(inp_file)
    return if type == "jpeg"

    out_file = inp_file.sub(".jpg", image_ext(type))
    File.copy(inp_file, out_file)
  rescue err
    puts err
  end

  private def image_type(file : String)
    `file -b "#{file}"`.split(" ").first?.try(&.downcase)
  end

  private def image_ext(type : String)
    type == "gzip" ? ".jpg.gz" : ".#{type}"
  end
end

worker = CV::Seed::FetchCovers.new
worker.fetch_yousuu! unless ARGV.includes?("-yousuu")
worker.fetch_chseed! unless ARGV.includes?("-chseed")
