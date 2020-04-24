require "colorize"
require "http/client"

module HtmlCrawler
  @@dir = "data/txt-inp"

  def dir
    @@dir
  end

  def dir=(@@dir : String)
  end

  def info_mkdir(site : String)
    FileUtils.mkdir_p(File.join(@@dir, site, "infos"))
  end

  def text_mkdir(site : String, csid : String)
    FileUtils.mkdir_p(File.join(@@dir, site, "texts", csid))
  end

  def info_path(site : String, bsid : String) : String
    File.join(@@dir, site, "infos", "#{bsid}.html")
  end

  def text_path(site : String, bsid : String, csid : String) : String
    File.join(@@dir, site, "texts", bsid, "#{csid}.html")
  end

  INFO_URLS = {
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

  def info_url(site : String, bsid : String) : String
    url_form = INFO_URLS[site]
    if site == "duokan8" || site == "paoshu8"
      group_id = (bsid.to_i // 1000).to_s
      url_form % [group_id, bsid]
    else
      url_form % bsid
    end
  end

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

  def text_url(site : String, bsid : String, csid : String) : String
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

  def fetch_info(site : String, bsid : String) : String
    file = info_path(site, bsid)

    if File.exists?(file)
      html = File.read(file)
    else
      html = fetch(info_url(site, bsid), encoding(site))
      File.write(file, html)
    end

    html
  end

  def fetch_text(site : String, bsid : String, csid : String) : String
    file = text_path(site, bsid, csid)

    if File.exists?(file)
      html = File.read(file)
    else
      html = fetch(text_url(site, bsid, csid), encoding(site))
      File.write(file, html)
    end

    html
  end

  def fetch(url : String, encoding : String = "UTF-8") : String
    do_fetch(url, tls(url), encoding)
  end

  def do_fetch(url : String, tls, encoding : String) : String
    HTTP::Client.get(url, tls: tls) do |res|
      return "404 Not Found!" if res.status_code == 404

      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try &.gets_to_end
    end
  rescue err
    puts "Error fetching <#{url.colorize(:red)}>: [#{err.class}] #{err.colorize(:red)}"
    sleep 500.milliseconds
    do_fetch(url, tls, encoding)
  end

  def encoding(site)
    case site
    when "jx_la", "hetushu", "paoshu8", "zhwenpg"
      "UTF-8"
    else
      "GBK"
    end
  end

  TLS = OpenSSL::SSL::Context::Client.insecure

  def tls(url : String)
    url.starts_with?("https") ? TLS : nil
  end

  extend self
end
