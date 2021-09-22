require "myhtml"
require "colorize"
require "file_utils"

require "../cutil/http_util"
require "../cutil/site_link"
require "../cutil/gzip_file"
require "../cutil/path_util"
require "../cutil/time_utils"

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
    when "paoshu8", "bqg_5200" then 2
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
    when "bqg_5200"
      Random.rand(200..500).milliseconds
    else
      10.milliseconds
    end
  end

  def remote?(sname : String, power : Int32 = 4)
    case sname
    when "chivi", "local", "zxcs_me", "zadzs", "thuyvicu", "hotupub"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "hetushu", "biqubao", "bxwxorg", "xbiquge"
      power > 0
    when "zhwenpg", "69shu", "paoshu8", "duokan8"
      power > 1
    else
      power > 3
    end
  end

  def fix_mftime(update_str : String, sname : String)
    return 0_i64 if sname == "hetushu" || sname == "zhwenpg"

    updated_at = TimeUtils.parse_time(update_str)
    updated_at += 12.hours if sname == "bqg_5200"

    upper_time = Time.utc
    updated_at < upper_time ? updated_at.to_unix : upper_time.to_unix
  rescue
    0_i64
  end
end
