require "mime"
require "colorize"
require "file_utils"

require "../../src/cutil/http_utils"
require "../../src/tsvfs/value_map"
require "../shared/seed_data"

class CV::FetchCovers
  def fetch_yousuu!
    dir = "_db/bcover/yousuu"
    ::FileUtils.mkdir_p(dir)

    out_queue = {} of String => String
    cover_map = cover_map("yousuu")

    Ysbook.query.order_by(voters: :desc).each_with_cursor(20) do |book|
      ynvid = book.id.to_s

      next unless image_url = cover_map.fval(ynvid)
      next if image_url.starts_with?("/")

      out_file = "#{dir}/#{ynvid}.jpg"
      next if existed?(out_file)

      out_queue[image_url] = out_file unless image_url.empty?
    end

    fetch!(out_queue, limit: 16)
  end

  REDO_ZERO = ARGV.includes?("redo_zero")

  def existed?(file : String)
    return false unless File.exists?(file)
    REDO_ZERO ? File.size(file) > 0 : true
  end

  def fetch_remote!
    queues = Hash(String, Hash(String, String)).new do |h, k|
      h[k] = {} of String => String
    end

    query = Cvbook.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |book|
      book.zhbooks.to_a.sort_by(&.zseed).first(3).each do |seed|
        # TODO: fix seed_zhwenpg script!
        next if seed.sname == "jx_la"

        out_file = "_db/bcover/#{seed.sname}/#{seed.snvid}.jpg"
        next if existed?(out_file)

        next unless image_url = cover_map(seed.sname).fval(seed.snvid)
        queues[seed.sname][image_url] = out_file unless image_url.empty?
      end
    end

    channel = Channel(Nil).new(queues.size)

    queues.each do |sname, queue|
      ::FileUtils.mkdir_p("_db/bcover/#{sname}")
      limit, delay = throttle_spec(sname)

      spawn do
        fetch!(queue, limit, delay)
      ensure
        channel.send(nil)
      end
    end

    queues.size.times { channel.receive }
  end

  def throttle_spec(sname : String)
    case sname
    when "shubaow" then {1, 1.seconds}
    when "duokan8" then {1, 750.milliseconds}
    when "zhwenpg" then {1, 500.milliseconds}
    when "paoshu8" then {2, 500.milliseconds}
    when "69shu"   then {4, 200.milliseconds}
    when "5200"    then {4, 100.milliseconds}
    else                {8, 50.milliseconds}
    end
  end

  MAP_CACHE = {} of String => ValueMap

  def cover_map(sname : String)
    MAP_CACHE[sname] ||= ValueMap.new("_db/zhbook/#{sname}/bcover.tsv", mode: 2)
  end

  def fetch!(queue : Hash(String, String), limit = 8, delay = 10.milliseconds)
    # remove invalid image urls
    queue = queue.reject { |link, _| link.starts_with?("/") }

    limit = queue.size if limit > queue.size
    channel = Channel(Nil).new(limit)

    queue.each_with_index(1) do |(link, file), idx|
      channel.receive if idx > limit

      spawn do
        HttpUtils.fetch_file(link, file, "#{idx}/#{queue.size}")
        fix_image_ext(file)
        sleep delay
      rescue err
        puts err.colorize.red
        ::FileUtils.touch(file)
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
