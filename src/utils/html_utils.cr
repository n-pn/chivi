require "colorize"
require "http/client"

module Utils
  SITE_URLS = {
    "nofff"   => "https://www.nofff.com/%s",
    "69shu"   => "https://www.69shu.com/%s/",
    "jx_la"   => "https://www.jx.la/book/%s/",
    "rengshu" => "http://www.rengshu.com/book/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/",
    "hetushu" => "https://www.hetushu.com/book/%s/index.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/",
    "zhwenpg" => "https://novel.zhwenpg.com/b.php?id=%s",
  }

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

  def self.info_url(site : String, bsid : String) : String
    url = SITE_URLS[site]
    if site == "duokan8" || site == "paoshu8"
      group_id = (bsid.to_i // 1000).to_s
      url % [group_id, bsid]
    else
      url % bsid
    end
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

  def self.fetch_html(url : String) : String
    # puts url.colorize(:red)
    download_html(url, tls_for(url), encoding_for(url))
  end

  def self.download_html(url : String, tls, encoding : String) : String
    HTTP::Client.get(url, tls: tls) do |res|
      return "404 Not Found!" if res.status_code == 404

      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try &.gets_to_end
    end
  rescue err
    puts "Error fetching <#{url.colorize(:red)}>: [#{err.class}] #{err.colorize(:red)}"
    sleep 500.milliseconds
    download_html(url, tls, encoding)
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
end
