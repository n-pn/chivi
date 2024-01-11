require "log"
require "yaml"
require "colorize"

require "http/client"
require "http_proxy"

struct HttpProxy
  include YAML::Serializable

  getter host : String
  getter port : Int32
  getter user : String
  getter pass : String

  getter rotate_url = ""
  getter auth_token = ""

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

  def self.make_headers(referer = "", cookie = "", content_type = "text/html")
    HTTP::Headers{
      "Origin"     => referer,
      "Referer"    => referer,
      "Cookie"     => cookie,
      "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0",

      "Content-Type" => content_type,
      # "Accept-Encoding" => "gzip, deflate, br",
    }
  end

  def self.make_client(uri : URI, proxy : HttpProxy? = nil)
    client = HTTP::Client.new(uri)
    client.connect_timeout = 10
    client.read_timeout = 20
    client.proxy = proxy.proxy_client if proxy
    client
  end

  def self.get_text(uri : URI, use_proxy : Bool = false)
  end

  def fetch(url : String, encoding = "UTF-8") : String
    args = {"-H", "user-agent: #{USER_AGENT}", "-L", "-k", "-s", "-m", "10", url}
    retry = 0

    loop do
      Log.debug { "[GET: #{url.colorize.magenta} {#{encoding}} (retry: #{retry})]" }

      Process.run("curl", args: args) do |proc|
        proc.output.set_encoding(encoding)
        html = proc.output.gets_to_end
        return html.sub(/(?<==|")#{encoding}(?=;|")/i, "utf-8") unless html.empty?
      end

      raise "[GET: #{url} failed after #{retry} attempts.]" if retry > 2
      retry += 1
    end
  end

  # def get_by_curl(url : String, encoding : String) : String
  #   cmd = "curl -L -k -s -f -m 30 '#{url}'"
  #   cmd += " | iconv -c -f #{encoding} -t UTF-8" if encoding != "UTF-8"
  #   `#{cmd}`
  # end

  # def crystal_get(url : String, encoding : String = "UTF-8")
  #   HTTP::Client.get(url) do |res|
  #     res.body_io.set_encoding(encoding, invalid: :skip)
  #     res.body_io.gets_to_end.lstrip
  #   end
  # end

  def fetch_file(url : String, file : String, lbl = "1/1") : Nil
    try = 0

    loop do
      puts "- <#{lbl.colorize.magenta}> [GET: #{url.colorize.magenta}, (try: #{try})]"

      `curl -L -k -s -f -m 200 '#{url}' -o '#{file}'`
      return if File.exists?(file)
    ensure
      try += 1
      sleep 500.milliseconds * try
      raise "[DL: #{url} failed after 3 attempts.]" if try > 2
    end
  end
end
