require "colorize"
require "file_utils"
require "http/client"

require "myhtml"

module ParseUtil
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

  def self.inner_text(dom, css : String)
    dom.css(css).first.inner_text.strip
  end

  def self.meta_content(dom, css : String)
    node = dom.css("meta[property=\"#{css}\"]").first
    node.attributes["content"]
  end
end
