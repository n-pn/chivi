require "colorize"
require "http/client"

module Utils
  def self.fetch_html(url : String) : String
    puts "- GET: [#{url.colorize.magenta}]"
    fetch_html(url, tls_for(url), encoding_for(url))
  end

  def self.fetch_html(url : String, tls : OpenSSL::SSL::Context::Client?, encoding : String) : String?
    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end)
    end
  rescue err
    puts "- <fetch_html> error fetching #{url.colorize.red}]: [#{err.class}] #{err.colorize.red}"
    sleep 500.milliseconds
    fetch_html(url, tls, encoding)
  end

  def self.encoding_for(url : String) : String
    {"jx.la", "hetushu", "paoshu8", "zhwenpg"}.each do |site|
      return "UTF-8" if url.includes?(site)
    end

    "GBK"
  end

  TLS = OpenSSL::SSL::Context::Client.insecure

  def self.tls_for(url : String) : OpenSSL::SSL::Context::Client?
    url.starts_with?("https") ? TLS : nil
  end
end
