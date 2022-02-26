require "myhtml"
require "colorize"
require "file_utils"

require "../../_util/http_util"
require "../../_util/site_link"
require "../../_util/gzip_file"
require "../../_util/path_util"
require "../../_util/time_utils"

module CV::RmUtil
  extend self

  def fetch(file : String, link : String, sname : String, ttl = 1.week, lbl = "1/1")
    expiry = sname == "jx_la" ? Time.utc(2010, 1, 1) : Time.utc - ttl

    GzipFile.new(file).read(expiry) do
      encoding = HttpUtil.encoding_for(sname)
      HttpUtil.get_html(link, encoding: encoding, lbl: lbl)
    end
  end

  def fetch_all(input : Array(Tuple(String, String)), sname : String, limit : Int32? = nil)
    limit ||= ideal_workers_count_for(sname)
    limit = input.size if limit > input.size

    channel = Channel(Nil).new(limit + 1)
    encoding = HttpUtil.encoding_for(sname)
    FileUtils.mkdir_p(File.dirname(input.first))

    input.each_with_index(1) do |(file, link), idx|
      channel.receive if idx > limit

      spawn do
        html = HttpUtil.get_html(link, encoding, lbl: "#{idx}/#{input.size}")
        File.write(file, html)
        sleep ideal_delayed_time_for(sname)
      rescue err
        puts err
      ensure
        channel.send(nil)
      end
    end

    limit.times { channel.receive }
  end

  def ideal_workers_count_for(sname : String) : Int32
    case sname
    when "zhwenpg", "shubaow"  then 1
    when "paoshu8", "biqu5200" then 2
    when "duokan8", "69shu"    then 4
    else                            6
    end
  end

  def ideal_delayed_time_for(sname : String)
    case sname
    when "shubaow"
      Random.rand(1000..2000).milliseconds
    when "zhwenpg"
      Random.rand(500..1000).milliseconds
    when "biqu5200"
      Random.rand(200..500).milliseconds
    else
      10.milliseconds
    end
  end
end
