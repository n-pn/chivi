require "log"
require "uri"
require "yaml"
require "colorize"
require "http/client"

require "zstd"
require "./dl_page"

struct DlHost
  include YAML::Serializable

  ##########

  property hostname : String
  property? insecure : Bool = false

  getter encoding = "GBK"
  getter cookie = ""

  getter chap_list_alg = "chdiv"
  getter chap_list_css = "#list > dl"

  getter chap_name_css = "h1"
  getter chap_body_css = "#content"

  getter chap_body_clean = [] of String

  getter book_id_regex = "(\\w+)\\D*$"
  getter chap_id_regex = "(\\w+)/(\\w+)\\D*$"

  getter book_path = "/book/%{bid}/"
  getter list_path = "/book/%{bid}/"
  getter chap_path = "/book/%{bid}/%{cid}.html"

  getter last_bid_url = "/"
  getter last_bid_css = "#newscontent > .r > ul > li:first-child > .s2 > a"

  def http_client : HTTP::Client
    HTTP::Client.new(@hostname, tls: !@insecure)
  end

  struct Autogen
    getter cache_dir : String
    getter book_id_regex : Regex
    getter chap_id_regex : Regex
    getter chap_body_clean : Array(Regex)

    def initialize(host : DlHost)
      @chap_body_clean = host.chap_body_clean.map { |x| Regex.new(x) }

      @book_id_regex = Regex.new(host.book_id_regex)
      @chap_id_regex = Regex.new(host.chap_id_regex)

      @cache_dir = "var/.html/#{host.hostname}"
      Dir.mkdir_p(@cache_dir)
    end
  end

  @[YAML::Field(ignore: true)]
  getter autogen : Autogen { Autogen.new(self) }

  def get_page(uri_path : String, ttl : Time::Span | Time::MonthSpan = 1.hours)
    file_path = cache_path(uri_path)
    return read_zst(file_path) if page_saved?(file_path, ttl: ttl)

    html = fetch_html(uri_path)
    save_zst(file_path, html)

    html
  end

  def get_last_bid(ttl = 1.days)
    page = DlPage.new(get_page(@last_bid_url, ttl: ttl))
    href = page.get(@last_bid_css, "href") || raise "invalid css query"
    Regex.new(@book_id_regex).match(href).try(&.[1])
  end

  def get_book_path(bid : Int32)
    @book_path % {bid: bid, div: bid // 1000}
  end

  def get_book_path(bid : String)
    @book_path % {bid: bid}
  end

  def get_list_path(bid : Int32)
    @list_path % {bid: bid, div: bid // 1000}
  end

  def get_list_path(bid : String)
    @list_path % {bid: bid}
  end

  def get_chap_path(bid : Int32, cid : Int32)
    @chap_path % {bid: bid, cid: cid, div: bid // 1000}
  end

  def get_chap_path(bid : String, cid : Int32 | String)
    @chap_path % {bid: bid, cid: cid}
  end

  def cache_path(uri_path : String, ext = "htm.zst")
    "#{self.autogen.cache_dir}/#{uri_path.gsub(/\W/, '_')}.#{ext}"
  end

  Log = ::Log.for("wndl")
  ::Log.setup_from_env

  def fetch_html(uri_path : String)
    fetch_page(uri_path) do |res|
      res.body_io.set_encoding(@encoding)
      html = res.body_io.gets_to_end

      return html if html.empty? || @encoding == "UTF-8"
      html.sub(/#{@encoding}|gb2312/i, "utf-8")
    end
  end

  U_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:110.0) Gecko/20100101 Firefox/110.0"

  def gen_headers(uri_path : String)
    scheme = @insecure ? "http" : "https"

    HTTP::Headers{
      "Referer"    => "#{scheme}://#{@hostname}#{uri_path}",
      "User-Agent" => U_AGENT,
      "Cookie"     => @cookie,
    }
  end

  def hts_headers(uri_path : String)
    HTTP::Headers{
      "Referer"          => "https://#{@hostname}#{uri_path}",
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "User-Agent"       => U_AGENT,
      "Cookie"           => @cookie,
    }
  end

  def fetch_page(uri_path : String, headers : HTTP::Headers = gen_headers(uri_path), &)
    Log.debug { "GET: #{hostname}#{uri_path}".colorize.magenta }
    http_client.get(uri_path, headers: headers) { |res| yield res }
  end

  @[AlwaysInline]
  def read_zst(path : String)
    File.open(path, "r") do |file|
      Zstd::Decompress::IO.open(file, &.gets_to_end)
    end
  end

  @[AlwaysInline]
  def save_zst(path : String, data : String)
    File.open(path, "w") do |file|
      Zstd::Compress::IO.open(file, level: 3, &.write(data.to_slice))
    end
  end

  @[AlwaysInline]
  def page_saved?(file : String, ttl : Time::Span | Time::MonthSpan)
    return false unless info = File.info?(file)
    info.modification_time > Time.utc - ttl
  end

  ###

  CONFS = Hash(String, self).from_yaml(File.read("var/_conf/dl_host.yml"))

  def self.load_by_name(hostname : String, &)
    hostbase = hostname.sub(/^www\./, "")

    CONFS[hostbase] ||= begin
      Log.info { "hostname #{hostname} not defined!".colorize.red }

      host = CONFS["[unknown]"].dup

      host.hostname = hostname
      host.insecure = yield

      host
    end
  end

  def self.load_by_name(hostname : String)
    load_by_name(hostname) { false }
  end

  def self.load_by_link(link : String)
    uri = URL.parse(link)
    hostname = URI.parse(href).hostname.as(String)
    load_by_name(hostname) { uri.scheme != "https" }
  end
end
