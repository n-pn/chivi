require "mime"
require "colorize"
require "file_utils"

require "../../src/utils/http_utils"
require "../../src/tabkv/value_map"
require "../../src/appcv/nv_info"

class CV::FetchCovers
  def fetch_yousuu!
    dir = "_db/bcover/yousuu"
    ::FileUtils.mkdir_p(dir)

    out_queue = {} of String => String
    cover_map = ValueMap.new("_db/_seeds/yousuu/bcover.tsv", mode: 2)

    NvFields.bhashes.each do |bhash|
      next unless ynvid = NvFields.yousuu.fval("bhash")

      out_file = "#{dir}/#{ynvid}.jpg"
      next if File.exists?(out_file)

      next unless image_url = cover_map.fval(ynvid)
      out_queue[image_url] = out_file unless image_url.empty?
    end

    fetch!(out_queue, limit: 16)
  end

  def fetch_remote!
    queues = Hash(String, Hash(String, String)).new do |h, k|
      h[k] = {} of String => String
    end

    NvFields.bhashes.each do |bhash|
      snames = NvChseed.get_list(bhash)

      snames.each do |sname|
        next if sname == "jx_la" || sname == "chivi"
        snvid = NvChseed.get_nvid(sname, bhash) || bhash

        out_file = "_db/bcover/#{sname}/#{snvid}.jpg"
        next if File.exists?(out_file)

        next unless image_url = cover_map(sname).fval(snvid)
        queues[sname][image_url] = out_file unless image_url.empty?
      end
    end

    channel = Channel(Nil).new(queues.size)

    queues.each do |sname, queue|
      ::FileUtils.mkdir_p("_db/bcover/#{sname}")

      limit, delayed =
        case sname
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

  MAP_CACHE = {} of String => ValueMap

  def cover_map(sname : String)
    MAP_CACHE[sname] ||= ValueMap.new("_db/_seeds/#{sname}/bcover.tsv", mode: 2)
  end

  def fetch!(queue : Hash(String, String), limit = 8, delayed = 10.milliseconds)
    # remove invalid image urls
    queue = queue.reject { |link, _| link.starts_with?("/") }

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

worker = CV::FetchCovers.new
worker.fetch_yousuu! unless ARGV.includes?("-yousuu")
worker.fetch_remote! unless ARGV.includes?("-remote")
