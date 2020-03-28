require "time"
require "colorize"
require "http/client"

module CrUtil
  class StatusCodeError < Exception; end

  extend self

  INFO_URLS = {
    "69shu"   => "https://www.69shu.com/%s",
    "nofff"   => "https://www.nofff.com/%s",
    "jx_la"   => "https://www.jx.la/book/%s/",
    "rengshu" => "http://www.rengshu.com/book/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/",
    "hetushu" => "https://www.hetushu.com/book/%s/index.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/",
    "zhwenpg" => "https://novel.zhwenpg.com/b.php?id=%s",
  }

  def info_url(site, bsid)
    url_form = INFO_URLS[site]
    if site == "duokan8" || site == "paoshu8"
      group_id = (bsid.to_i // 1000).to_s
      url_form % [group_id, bsid]
    else
      url_form % bsid
    end
  end

  UTF = Set.new ["jx_la", "hetushu", "paoshu8", "zhwenpg"]
  TLS = OpenSSL::SSL::Context::Client.insecure

  def fetch_info(site, bsid)
    book_url = info_url(site, bsid)
    tls = book_url.starts_with?("https") ? TLS : nil
    encoding = UTF.includes?(site) ? "UTF-8" : "GBK"

    fetch_html(book_url, tls, encoding)
  end

  VERBOSE = ARGV.includes?("verbose")

  def fetch_html(url, tls, encoding)
    puts "HIT: #{url}".colorize(:blue) if VERBOSE

    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.gets_to_end
    end
  rescue err
    puts "Error fetching [#{url}]: #{err}".colorize(:red)
    sleep 500.milliseconds
    puts "Retrying.."

    fetch_html(url, tls, encoding)
  end

  def outdated?(file, timespan = 10.hours)
    return true unless File.exists?(file)
    mtime = File.info(file).modification_time
    Time.local - mtime > timespan
  end

  # def fix_order(volumes)
  #   order = 0
  #   volumes.sort_by do |volume|
  #     if volume
  #     index = LABELS.index { |i| volume[:label].includes?(i) }
  #     order += 1 unless index
  #     {order, index || -1}
  #   end
  # end
end

# puts "第九十八卷".match(/\p{Nd}+/)
# puts "1223434".match(/\p{N}+/)
