require "colorize"
require "http/client"

# require "crest"

module Chivi::HttpUtils
  extend self

  HEADERS = HTTP::Headers{
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36",
  }

  CLIENTS = {} of String => HTTP::Client

  def client_for(url : String)
    client_for(URI.parse(url))
  end

  def client_for(uri : URI)
    CLIENTS[uri.host.not_nil!] ||= begin
      client = HTTP::Client.new(uri)

      client.dns_timeout = 20
      client.connect_timeout = 20
      client.read_timeout = 40

      client
    end
  end

  def get_html(url : String) : String
    puts "-- GET: [#{url}]".colorize.magenta

    uri = URI.parse(url)
    client = client_for(uri)
    encoding = encoding_for(uri)

    get_html(client, path: uri.full_path.not_nil!, encoding: encoding)
  end

  def get_html(client : HTTP::Client, path : String, encoding = "GBK", try = 1)
    client.get(path, headers: HEADERS) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.try(&.gets_to_end) || "404 Not Found!"
    end
  rescue err
    puts "-- Error fetching [#{path}]: #{err} (try: #{try})".colorize.red
    raise "500 Server Error!" if try > 3

    sleep 500.milliseconds * try
    get_html(client, path, encoding, try: try + 1)
  end

  # def tls_for(uri : URI)
  #   case uri
  #   when "novel.zhwenpg.com"
  #     OpenSSL::SSL::Context::Client.insecure
  #   else
  #     uri.scheme == "https"
  #   end
  # end

  def encoding_for(uri : URI)
    case uri.host
    when "www.jx.la",
         "www.hetushu.com",
         "www.paoshu8.com",
         "novel.zhwenpg.com",
         "www.zxcs.me"
      "UTF-8"
    else
      "GBK"
    end
  end
end
