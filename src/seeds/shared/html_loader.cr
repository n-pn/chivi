require "colorize"
require "file_utils"

module Cv::HtmlLoader
  TTL = Time.utc(2000, 1, 1)

  def load!(file : String, link : String, ttl = 1.week, label = "1/1", encoding = "UTF-8")
    unless html = read(file, ttl: ttl)
      html = HttpUtil.get_html(link, encoding: encoding, label: lbl)
      save!(file, html)
    end

    html
  end

  def encoding(sname : String) : String
    case sname
    when "jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me", "bxwxorg"
      "UTF-8"
    else
      "GBK"
    end
  end

  def read(file : String, ttl = TTL) : String?
    expiry = ttl.is_a?(Time) ? ttl : Time.utc - ttl
    return if staled?(file, expiry)

    return File.read(file) unless file.ends_with?(".gz")

    File.open(file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end

  def save!(file : String, html : String)
    ::FileUtils.mkdir_p(File.dirname(file))

    File.open(file, "w") do |io|
      if file.ends_with?(".gz")
        Compress::Gzip::Writer.open(io, &.print(html))
      else
        io.print(html)
      end
    end
  end

  def staled?(file : String, expiry : Time) : Bool
    return true unless stats = File.info?(file)
    stats.modification_time < expiry
  end
end
