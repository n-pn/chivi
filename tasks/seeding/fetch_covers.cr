require "mime"
require "colorize"
require "file_utils"

require "../../src/mapper/value_map"
require "../../src/_utils/http_utils"

class CV::Seed::FetchCovers
  def fetch_yousuu!
    dir = "_db/bcover/yousuu"
    ::FileUtils.mkdir_p(dir)

    queue = {} of String => String
    covers = ValueMap.new("_db/_seeds/yousuu/bcover.tsv", mode: 2)
    s_nvids = ValueMap.new("_db/nvdata/nvinfos/yousuu.tsv", mode: 2).vals

    s_nvids.each do |vals|
      s_nvid = vals.first
      out_file = "#{dir}/#{s_nvid}.jpg"
      next if File.exists?(out_file)

      next unless image_url = covers.fval(s_nvid)
      queue[image_url] = out_file unless image_url.empty?
    end

    fetch!(queue, limit: 16)
  end

  def fetch_remote!
    queues = Hash(String, Hash(String, String)).new do |h, k|
      h[k] = {} of String => String
    end

    input = ValueMap.new("_db/nvdata/nvinfos/source.tsv", mode: 2).vals
    input.each do |source|
      source.each do |entry|
        s_name, s_nvid = entry.split("/")
        next if s_name == "jx_la"

        out_file = "_db/bcover/#{s_name}/#{s_nvid}.jpg"
        next if File.exists?(out_file)

        next unless image_url = cover_map(s_name).fval(s_nvid)
        queues[s_name][image_url] = out_file unless image_url.empty?
      end
    end

    channel = Channel(Nil).new(queues.size)

    queues.each do |s_name, queue|
      limit, delayed =
        case s_name
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

  def cover_map(s_name : String)
    cache[s_name] ||= ValueMap.new("_db/_seeds/#{s_name}/bcover.tsv", mode: 2)
  end

  def fetch!(queue : Hash(String, String), limit = 8, delayed = 10.milliseconds)
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
worker.fetch_remote! unless ARGV.includes?("-remote")
