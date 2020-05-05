require "colorize"
require "http/client"

module SpiderUtil
  # html utils

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
    fetch_html(url, tls_for(url), encoding_for(url))
  end

  def self.fetch_html(url : String, tls, encoding : String) : String
    HTTP::Client.get(url, tls: tls) do |res|
      return "404 Not Found!" if res.status_code == 404

      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end)
    end
  rescue err
    puts "Error fetching <#{url.colorize(:red)}>: [#{err.class}] #{err.colorize(:red)}"
    sleep 500.milliseconds
    fetch_html(url, tls, encoding)
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

  # file utils

  INP_DIR = "data/.inits/txt-inp"

  def self.info_dir(site : String)
    File.join(INP_DIR, site, "infos")
  end

  def self.info_path(site : String, bsid : String)
    File.join(info_dir(site), "#{bsid}.html")
  end

  def self.text_dir(site : String, bsid : String)
    File.join(INP_DIR, site, "texts", bsid)
  end

  def self.text_path(site : String, bsid : String, csid : String)
    File.join(text_dir(site, bsid), "#{csid}.html")
  end

  def self.read_file(file : String, expiry : Time | Time::Span)
    return if outdated?(file, expiry)
    File.read(file)
  end

  def self.outdated?(file : String, span : Time::Span)
    outdated?(file, Time.utc - span)
  end

  def self.outdated?(file : String, etag : Time = Time.utc - 3.hours)
    return true unless File.exists?(file)
    etag > File.info(file).modification_time
  end

  # fixes data

  NUMBERS = "零〇一二两三四五六七八九十百千"

  VOL_RE_0 = /^(第[#{NUMBERS}\d]+[集卷].*)(第?[#{NUMBERS}\d]+[章节幕回].*)$/
  VOL_RE_1 = /^(第[#{NUMBERS}\d]+[集卷].*)(（\p{N}+）.*)$/

  def self.split_title(title)
    volume = "正文"
    if match = VOL_RE_0.match(title) || VOL_RE_1.match(title)
      _, volume, title = match
      volume = clean_title(volume)
    end

    {fix_title(title), volume}
  end

  TITLE_RE_0 = /^\d+\.\s*第/
  TITLE_RE_1 = /^第?([#{NUMBERS}\d]+)([章节幕回折])[、：,.:\s]?(.*)$/
  TITLE_RE_2 = /^([#{NUMBERS}\d]+)[、：,.:\s]?(.*)$/
  TITLE_RE_3 = /^（(\p{N}+)）(.*)$/

  def self.fix_title(title)
    if match = TITLE_RE_0.match(title)
      return clean_title(title.sub(/^\d+\.\s*第/, "第"))
    end

    label = "章"

    if match = TITLE_RE_1.match(title)
      _, number, label, title = match
    elsif match = TITLE_RE_2.match(title)
      _, number, title = match
    elsif match = TITLE_RE_3.match(title)
      _, number, title = match
    else
    end

    clean_title("第#{number}#{label} #{title}")
  end

  def self.clean_title(title)
    title.strip.split(/\p{Z}+/).join(" ")
  end

  # parses time

  LOCATION = Time::Location.fixed(3600 * 8)
  FORMATS  = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

  def self.parse_time(input : String)
    FORMATS.each do |format|
      return Time.parse(input, format, LOCATION).to_unix_ms
    rescue
      next
    end

    puts "Error parsing <#{input}>: unknown time format!".colorize(:red)
    0_i64
  end
end
