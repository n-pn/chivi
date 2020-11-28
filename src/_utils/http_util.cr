require "colorize"
require "http/client"

module HttpUtil
  extend self

  UTF8_SITES = {"qu_la", "jx_la", "hetushu", "paoshu8", "zhwenpg"}

  def encoding_for(site : String) : String
    UTF8_SITES.includes?(site) ? "UTF-8" : "GBK"
  end

  alias SSL = OpenSSL::SSL::Context::Client

  def fetch_html(url : String, encoding = "GBK") : String
    puts "-- HIT: [#{url}] --".colorize.magenta
    tls = url.starts_with?("https") ? SSL.insecure : nil
    html = fetch_html(url, encoding, tls, retry: 0)
  end

  HEADERS = HTTP::Headers{
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
  }

  def fetch_html(url : String, encoding : String, tls : SSL?, retry = 0)
    HTTP::Client.get(url, tls: tls, headers: HEADERS) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end) || "404 Not Found!"
    end
  rescue err
    puts "-- error [#{url}]: {#{err.class}} #{err} (retry: #{retry}) --".colorize.red

    retry += 1
    return "500 Server Error!" if retry > 2 # stop trying after 2 times

    sleep 500.milliseconds * retry
    fetch_html(url, encoding, tls, retry)
  end
end
