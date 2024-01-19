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
  ENCODING = Hash(String, String).from_yaml({{ read_file(__DIR__ + "/fixed/encoding.yml") }})

  def self.encoding_for(hostname : String) : String
    ENCODING[hostname]? || "GB18030"
  end

  def self.content_type(type : String)
    case type
    when "text" then "text/plain"
    when "form" then "application/x-www-form-urlencoded"
    when "json" then "application/json"
    else             raise "invalid content type"
    end
  end

  def self.gen_headers(referer = "", cookie = "", content_type = "text/html")
    HTTP::Headers{
      "Origin"          => referer,
      "Referer"         => referer,
      "Cookie"          => cookie,
      "User-Agent"      => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0",
      "Content-Type"    => content_type,
      "Accept-Encoding" => "gzip, deflate, br",
    }
  end

  def self.http_client(uri : URI, proxy : HttpProxy? = nil)
    client = HTTP::Client.new(uri)
    client.connect_timeout = 10
    client.read_timeout = 20
    client.proxy = proxy.proxy_client if proxy
    client
  end

  def self.fetch(url : String, headers : HTTP::Headers? = nil,
                 encoding : String? = "UTF-8", use_proxy : Bool = false)
    proxy = HttpProxy.pick_one if use_proxy
    fetch(URI.parse(url), headers, encoding, proxy: proxy)
  end

  def self.fetch(uri : URI, headers : HTTP::Headers? = nil,
                 encoding : String? = "UTF-8", proxy : HttpProxy? = nil)
    http_client(uri, proxy).get(uri.request_target, headers: headers) do |res|
      case res.status
      when .success?
        proxy.success_count += 1 if proxy
        gets_to_end(res.body_io, uri.hostname.as(String), encoding)
      when .redirection?
        location = URI.parse(res.headers["location"])
        fetch(location, headers: headers, encoding: encoding, proxy: proxy)
      else
        proxy.failure_count += 1 if proxy
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
end
