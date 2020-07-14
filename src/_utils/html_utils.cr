require "colorize"
require "http/client"

module Utils
  alias SSL = OpenSSL::SSL::Context::Client
  TLS = SSL.insecure

  def self.tls_for(url : String) : SSL?
    url.starts_with?("https") ? TLS : nil
  end

  def self.encoding_for(url : String) : String
    {"jx.la", "hetushu", "paoshu8", "zhwenpg"}.each do |site|
      return "UTF-8" if url.includes?(site)
    end

    "GBK"
  end

  def self.fetch_html(url : String) : String
    puts "- GET: [#{url.colorize.magenta}]"
    fetch_html(url, tls_for(url), encoding_for(url), retry: 0)
  end

  def self.fetch_html(url : String, tls : SSL?, encoding : String, retry = 0) : String
    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end) || "404 Not Found!"
    end
  rescue err
    puts "- <fetch_html> error fetching #{url.colorize.red}]: \
            [#{err.class}] #{err.colorize.red}"
    if retry < 3
      sleep 500.milliseconds
      fetch_html(url, tls, encoding, retry + 1)
    else
      "404 Not Found!"
    end
  end
end
