require "colorize"
require "http/client"

module HttpUtil
  extend self

  LABEL = "http_util"
  alias SSL = OpenSSL::SSL::Context::Client

  def fetch_html(url : String, encoding = "GBK") : String
    puts "-- <#{LABEL}> GET: [#{url}] --".colorize.magenta

    tls = url.starts_with?("https") ? SSL.insecure : nil
    html = do_fetch(url, tls, encoding, retry: 0)
  end

  UTF8_SITES = {"jx_la", "hetushu", "paoshu8", "zhwenpg"}

  def encoding_for(site : String) : String
    UTF8_SITES.includes?(site) ? "UTF-8" : "GBK"
  end

  def do_fetch_html(url : String, tls : SSL?, encoding : String, retry = 0)
    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end) || "404 Not Found!"
    end
  rescue err
    puts "- <#{LABEL.colorize.red}> error fetching [#{url.colorize.red}]: \
            {#{err.class}} #{err.colorize.red} (retry: #{retry.colorize.red})"

    return "500 Server Error!" if retry > 2 # stop trying after 3 times
    sleep 500.milliseconds
    fetch(url, tls, encoding, retry + 1)
  end
end
