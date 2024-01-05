require "json"
require "yaml"
require "http/client"
require "http_proxy"

struct RotateProxy
  include YAML::Serializable
  getter host : String
  getter port : Int32
  getter user : String
  getter pass : String

  getter change_ip_api = ""

  def proxy_client
    HTTP::Proxy::Client.new(@host, port: @port, username: @user, password: @pass)
  end

  def change_ip!(retry = 4)
    return if @change_ip_api.blank?

    retry.times do |i|
      Log.info { "reseting IP address (try: #{i})" }

      res = HTTP::Client.get(@change_ip_api)
      break if res.status.success?

      if @change_ip_api.includes?("proxyxoay.net")
        delay = res.body.match!(/\s(\d+)\s/)[1].to_i
      else
        delay = 10 * 2 << i
      end

      Log.info { "sleeping #{delay} seconds before retrying" }
      sleep delay.seconds
    end
  end

  class_getter all_entries : Array(self) do
    Array(self).from_yaml(File.read("var/_conf/rotate-proxies.yml"))
  end
end

module SP::BdUtil
  WEB_URL = "https://fanyi.baidu.com"
  WEB_URI = URI.parse(WEB_URL)

  def self.client(proxy : RotateProxy? = nil)
    client = HTTP::Client.new(WEB_URI)

    client.connect_timeout = 5
    client.read_timeout = 10

    client.proxy = proxy.proxy_client if proxy
    client
  end

  def self.reset_auth!(proxy : RotateProxy? = nil)
    @@cookie = nil
    @@auth = nil
    proxy.change_ip! if proxy
  end

  class_getter cookie : String do
    self.client.get("/", &.headers["Set-Cookie"])
  end

  def self.gen_headers(content_type = "application/x-www-form-urlencoded")
    HTTP::Headers{
      "Origin"       => WEB_URL,
      "Referer"      => WEB_URL,
      "User-Agent"   => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0",
      "Content-Type" => content_type,
      "Cookie"       => self.cookie,
    }
  end

  record Auth, token : String, gtk : String

  class_getter auth : Auth do
    self.client(true).get("/", headers: gen_headers) do |res|
      body = res.body_io.gets_to_end
      Auth.new(
        token: body.match!(/token: '(.+)'/)[1],
        gtk: body.match!(/window.gtk = ["'](.+)['"]/)[1]
      )
    end
  end

  def self.sign_query(query : String, gtk : String = self.auth.gtk)
    chars = query.each_grapheme.to_a

    if chars.size > 30
      query = String.build do |io|
        chars.first(10).join(io)
        chars[chars.size // 2 - 5, 10].join(io)
        chars.last(10).join(io)
      end
    end

    m, s = gtk.split('.', 2).map(&.to_u32)

    x = query.each_byte.reduce(m) do |a, b|
      a &+= b
      a &+= a << 10
      a ^ a >> 6
    end

    x &+= x << 3
    x ^= x >> 11
    x &+= x << 15

    x = (x ^ s) % 1_000_000
    "#{x}.#{x ^ m}"
  end
end
