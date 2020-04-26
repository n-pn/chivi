require "colorize"
require "file_utils"
require "http/client"

require "myhtml"

module LeechUtil
  DIR = "data/txt-inp"

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

  # def text_mkdir(site : String, csid : String)
  #   FileUtils.mkdir_p(File.join(DIR, site, "texts", csid))
  # end

  def self.text_path(site : String, bsid : String, csid : String) : String
    File.join(DIR, site, "texts", bsid, "#{csid}.html")
  end

  def self.text_url(site : String, bsid : String, csid : String) : String
    url = TEXT_URLS[site]
    case site
    when "zhwenpg"
      url % csid
    when "duokan8", "paoshu8"
      group = (bsid.to_i // 1000).to_s
      url % [group, bsid, csid]
    else
      url % [bsid, csid]
    end
  end

  # def text_html(site : String, bsid : String, csid : String, save = false) : String
  #   url = text_url(site, bsid, csid)
  #   file = text_path(site, bsid, csid)
  #   fetch_html(url, file, save: save)
  # end

  def self.fetch_html(url : String) : String
    do_fetch_html(url, tls_for(url), encoding_for(url))
  end

  def self.do_fetch_html(url : String, tls, encoding : String) : String
    HTTP::Client.get(url, tls: tls) do |res|
      return "404 Not Found!" if res.status_code == 404

      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try &.gets_to_end
    end
  rescue err
    puts "Error fetching <#{url.colorize(:red)}>: [#{err.class}] #{err.colorize(:red)}"
    sleep 500.milliseconds
    do_fetch_html(url, tls, encoding)
  end

  def self.encoding_for(url : String)
    {"jx.la", "hetushu", "paoshu8", "zhwenpg"}.each do |site|
      return "UTF-8" if url.includes?(site)
    end

    "GBK"
  end

  TLS = OpenSSL::SSL::Context::Client.insecure

  def self.tls_for(url : String)
    url.starts_with?("https") ? TLS : nil
  end

  def self.outdated?(file : String, span = 3.hours)
    return true unless File.exists?(file)
    mtime = File.info(file).modification_time
    mtime < Time.utc - span
  end

  def self.dom_text(dom, selector)
    dom.css(selector).first.inner_text.strip
  end
end
