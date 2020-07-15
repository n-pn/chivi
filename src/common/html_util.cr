require "colorize"
require "http/client"

require "./file_util"

module HtmlUtil
  extend self

  alias SSL = OpenSSL::SSL::Context::Client

  def fetch(url : String, encoding = "GBK") : String
    puts "-- GET: [#{url}] --".colorize.magenta

    tls = url.starts_with?("https") ? SSL.insecure : nil
    html = do_fetch(url, tls, encoding, retry: 0)
  end

  UTF8_SITES = {"jx_la", "hetushu", "paoshu8", "zhwenpg"}

  def encoding_for(site : String) : String
    UTF8_SITES.includes?(site) ? "UTF-8" : "GBK"
  end

  def do_fetch(url : String, tls : SSL?, encoding : String, retry = 0) : String
    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end) || "404 Not Found!"
    end
  rescue err
    puts "- <html_util> error fetching #{url.colorize.red}]: \
    [#{err.class}] #{err.colorize.red}"
    if retry < 3
      sleep 500.milliseconds
      fetch(url, tls, encoding, retry + 1)
    else
      "404 Not Found!"
    end
  end
end
