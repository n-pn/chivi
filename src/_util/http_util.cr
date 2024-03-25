require "log"
require "icu"
require "yaml"
require "colorize"

require "http/client"
require "http_proxy"

class HttpProxy
  include YAML::Serializable

  getter host : String
  getter port : Int32
  getter user : String
  getter pass : String

  getter rotate_url = ""
  getter auth_token = ""

  property success_count = 0
  property failure_count = 0

  def proxy_client
    HTTP::Proxy::Client.new(@host, port: @port, username: @user, password: @pass)
  end

  def rotate_ip!(retry = 4)
    Log.info { "reseting IP address using: #{@rotate_url}" }
    return if @rotate_url.blank?

    retry.times do |i|
      return unless delay = call_rotator!(retry)
      Log.info { "sleeping #{delay} seconds before retrying" }
      sleep delay.seconds
    end
  end

  def call_rotator!(retry = 1)
    unless @auth_token.blank?
      headers = HTTP::Headers{"Authentication" => "Bearer #{@auth_token}"}
    end

    res = HTTP::Client.get(@rotate_url, headers: headers)
    return if res.status.success?

    if @rotate_url.includes?("proxyxoay.net")
      res.body.match!(/\s(\d+)\s/)[1].to_i
    else
      10 * 2 << retry
    end
  end

  class_getter all_entries : Array(self) do
    Array(self).from_yaml(File.read("var/_conf/http-proxies.yml"))
  rescue
    [] of self
  end

  def self.pick_one
    self.all_entries.last?
  end
end

module HttpUtil
  def self.content_type(type : String)
    case type
    when "text" then "text/plain"
    when "form" then "application/x-www-form-urlencoded"
    when "json" then "application/json"
    else             raise "invalid content type"
    end
  end

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0"

  def self.gen_headers(url = "", type : Symbol = :html, auth : String? = nil)
    # headers = HTTP::Headers{"Origin" => url, "Referer" => url, "User-Agent" => USER_AGENT, "Accept-Encoding" => "gzip, deflate, br"}
    headers = HTTP::Headers{"Origin" => url, "Referer" => url, "User-Agent" => USER_AGENT}

    if auth
      header = auth.starts_with?("Bearer") ? "Authorization" : "Cookie"
      headers[header] = auth
    end

    case type
    when :xhr
      headers["X-Requested-With"] = "XMLHttpRequest"
      headers["Content-Type"] = "application/x-www-form-urlencoded"
    when :form
      headers["Content-Type"] = "application/x-www-form-urlencoded"
    when :json
      headers["Content-Type"] = "application/json"
    when :html
      headers["Content-Type"] = "text/html"
    else
      headers["Content-Type"] = "text/plain"
    end

    headers
  end

  def self.http_client(uri : URI, proxy : HttpProxy? = nil)
    client = HTTP::Client.new(uri)
    client.connect_timeout = 10.seconds
    client.read_timeout = 20.seconds
    client.proxy = proxy.proxy_client if proxy
    client
  end

  @[AlwaysInline]
  def self.fetch(url : String, headers : HTTP::Headers? = nil,
                 encoding : String? = nil, use_proxy : Bool = false)
    proxy = HttpProxy.pick_one if use_proxy
    do_fetch(URI.parse(url), headers, encoding, proxy: proxy)
  end

  @[AlwaysInline]
  def self.fetch(url : URI, headers : HTTP::Headers? = nil,
                 encoding : String? = nil, use_proxy : Bool = false)
    proxy = HttpProxy.pick_one if use_proxy
    do_fetch(uri, headers, encoding, proxy: proxy)
  end

  def self.do_fetch(uri : URI, headers : HTTP::Headers? = nil,
                    encoding : String? = nil, proxy : HttpProxy? = nil)
    http_client(uri, proxy).get(uri.request_target, headers: headers) do |res|
      case res.status
      when .success?
        proxy.success_count &+= 1 if proxy
        gets_to_end(res.body_io, uri.hostname.as(String), encoding: encoding)
      when .redirection?
        location = URI.parse(res.headers["location"])
        do_fetch(uri: location, headers: headers, encoding: encoding, proxy: proxy)
      else
        proxy.failure_count += 1 if proxy
        Log.error { res.body_io.gets_to_end }
        raise "http error: #{res.status_code}"
      end
    end
  end

  CSDET = ICU::CharsetDetector.new

  def self.gets_to_end(body : IO, hostname : String, encoding : String? = nil)
    if encoding ||= ENCODING[hostname]?
      html = body.tap(&.set_encoding(encoding, invalid: :skip)).gets_to_end
    else
      blob = body.getb_to_end
      sample = String.new(blob[0..1000])
      encoding = ENCODING[hostname] = CSDET.detect(sample).name
      html = String.new(blob, encoding: encoding, invalid: :skip)
    end

    encoding == "UTF-8" ? html : html.sub(/#{encoding}|gbk|gb2312/i, "utf-8")
  end

  ENCODING = {
    "hetushu.com"       => "UTF-8",
    "jx.la"             => "UTF-8",
    "zxcs.me"           => "UTF-8",
    "xswang.com"        => "UTF-8",
    "novel.zhwenpg.com" => "UTF-8",
    "133txt.com"        => "UTF-8",
    "kanshu8.net"       => "UTF-8",
    "yannuozw.com"      => "UTF-8",
    "uuks.org"          => "UTF-8",
    "bqxs520.net"       => "UTF-8",
    "biqugse.com"       => "UTF-8",
    "sdyfcm.com"        => "UTF-8",
    "nofff.com"         => "UTF-8",
    "bxwxorg.com"       => "UTF-8",
    "paoshu8.com"       => "UTF-8",
  }

  def self.encoding_for(hostname : String) : String
    ENCODING[hostname]? || "GB18030"
  end
end
