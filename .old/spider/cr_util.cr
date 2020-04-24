require "time"
require "colorize"
require "http/client"

module Spider::CrUtil
  class StatusCodeError < Exception; end

  TEXT_URLS = {
    "nofff"   => "https://www.nofff.com/%s/%s/",
    "69shu"   => "https://www.69shu.com/txt/%s/%s",
    "jx_la"   => "https://www.jx.la/book/%s/%s.html",
    "rengshu" => "http://www.rengshu.com/book/%s/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/%s.html",
    "hetushu" => "https://www.hetushu.com/book/%s/%s.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/%s.html",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/%s.html",
    "zhwenpg" => "https://novel.zhwenpg.com/r.php?id=%s",
  }

  def text_url(site : String, bsid : String, csid : String)
    url_form = TEXT_URLS[site]
    case site
    when "zhwenpg"
      url_form % csid
    when "duokan8", "paoshu8"
      group = (bsid.to_i // 1000).to_s
      url_form % [group, bsid, csid]
    else
      url_form % [bsid, csid]
    end
  end

  def encoding_for(site)
    case site
    when "jx_la", "hetushu", "paoshu8", "zhwenpg"
      "UTF-8"
    else
      "GBK"
    end
  end

  TLS = OpenSSL::SSL::Context::Client.insecure

  def fetch_html(url : String, site : String)
    puts "GET: <#{url.colorize(:blue)}>"
    tls = url.starts_with?("https") ? TLS : nil
    do_fetch_html(url, tls, encoding_for(site))
  end

  def do_fetch_html(url : String, tls, encoding : String)
    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.gets_to_end
    end
  rescue err
    puts "Error fetching <#{url.colorize(:red)}>: [#{err.class}] #{err.colorize(:red)}"
    return "404 Not Found!" if err.class == NilAssertionError

    sleep 500.milliseconds
    puts "Retrying.."
    do_fetch_html(url, tls, encoding)
  end

  def outdated?(file : String, time = 2.hours)
    return true unless File.exists?(file)
    mtime = File.info(file).modification_time
    Time.utc - mtime > time
  end

  extend self
end

# puts "第九十八卷".match(/\p{Nd}+/)
# puts "1223434".match(/\p{N}+/)
