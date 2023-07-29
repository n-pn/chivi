require "log"
require "yaml"
require "http/client"

# Log.setup_from_env

module Rmutil
  def self.still_fresh?(file_path : String, stale : Time) : Bool
    File.info?(file_path).try(&.modification_time.> stale) || false
  end

  def self.clean_text(input : String)
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t\n", " ").strip
  end
end

class Rmconf
  include YAML::Serializable

  property seedname : String
  property seedtype : Int32 = 0
  property seedrank : Int32 = 0

  ####

  property hostname : String
  property encoding = "GBK"
  property? insecure = false
  property cookie = ""

  property time_fmt = "%F %T"

  ####

  property book_id_re = "(\\d+)$"
  @[YAML::Field(ignore: true)]
  getter book_id_regex : Regex { Regex.new(@book_id_re) }

  property chap_id_re = "(\\d+)\\D*$"
  @[YAML::Field(ignore: true)]
  getter chap_id_regex : Regex { Regex.new(@chap_id_re) }

  property bid_cid_re = "(?<bid>\\d+)/(?<cid>\\d+)\\D$"
  @[YAML::Field(ignore: true)]
  getter bid_cid_regex : Regex { Regex.new(@bid_cid_re) }

  ###

  property mbid_path = "/"
  property mbid_elem = "#newscontent > .r > ul > li:first-child > .s2 > a"

  ###

  property book_path = "/book/%{bid}/"
  property book_type = ""

  property book_latest = {"meta[property=\"og:novel:latest_chapter_url\"]", "content"}
  property book_update : {String, String} | Nil = {"meta[property=\"og:novel:update_time\"]", "content"}
  property book_status : {String, String} | Nil = {"meta[property=\"og:novel:status\"]", "content"}

  ###

  property cata_path = "/book/%{bid}/"
  property cata_type = "subdiv"
  property cata_elem = "#list > dl"

  property cata_latest = {"meta[property=\"og:novel:status\"]", "content"}
  property cata_update : {String, String} | Nil = {"meta[property=\"og:novel:update_time\"]", "content"}
  property cata_status : {String, String} | Nil = {"meta[property=\"og:novel:status\"]", "content"}

  ###

  property chap_path = "/book/%{bid}/%{cid}.html"
  property chap_type = ""

  property chap_name = "h1"
  property chap_body = "#content"

  property chap_body_scrub : String? = nil
  @[YAML::Field(ignore: true)]
  getter chap_scrub_re : Regex { Regex.new(@chap_body_scrub || ".") }

  ###

  # getter root_link : String do
  #   String.build do |io|
  #     io << (@conf.insecure ? "http" : "https")
  #     io << "://" << @hostname
  #   end
  # end

  def full_path(path : String = "/")
    String.build do |io|
      io << (self.insecure? ? "http" : "https") << "://" << @hostname << path
    end
  end

  ###

  def extract_bid(href : String)
    self.book_id_regex.match!(href)[1]
  end

  def extract_cid(href : String)
    self.chap_id_regex.match!(href)[1]
  end

  def extract_ids(href : String)
    match = self.bid_cid_re.match!(href)
    {match["bid"], match["cid"]}
  end

  TIMEZONE = Time::Location.fixed(3600 * 8) # chinese timezone

  def parse_time(date : String)
    time = Time.parse(date, @time_fmt, TIMEZONE) + 1.days
    time > Time.utc ? Time.utc : time
  end

  ####

  ROOT_DIR = "/2tb/var.chivi/.keep"
  BMID_DIR = "#{ROOT_DIR}/latest/%{name}.htm"
  BOOK_DIR = "#{ROOT_DIR}/wnbook/%{site}/%{bid}.htm"
  CHAP_DIR = "#{ROOT_DIR}/wnchap/%{site}/%{bid}/%{cid}.htm"

  def mbid_file_path
    BMID_DIR % {name: @seedname}
  end

  @[AlwaysInline]
  private def gen_div(bid : Int32 | String)
    (bid.to_i // 1000) rescue 0
  end

  def make_book_path(bid : Int32 | String)
    @book_path % {div: gen_div(bid), bid: bid}
  end

  def book_file_path(bid : Int32 | String)
    BOOK_DIR % {site: @hostname, bid: bid}
  end

  def make_cata_path(bid : Int32 | String)
    @cata_path % {div: gen_div(bid), bid: bid}
  end

  def cata_file_path(bid : Int32 | String)
    file_path = book_file_path(bid)
    same_page = @book_path == @cata_path
    same_page ? file_path : file_path.sub(".htm", "-cata.htm")
  end

  def make_chap_path(bid : Int32 | String, cid : Int32 | String)
    @chap_path % {div: gen_div(bid), bid: bid, cid: cid}
  end

  def chap_file_path(bid : Int32 | String, cid : Int32 | String)
    CHAP_DIR % {site: @hostname, bid: bid, cid: cid}
  end

  ###

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"

  def headers(uri_path : String)
    HTTP::Headers{
      "Referer"    => full_path(uri_path),
      "User-Agent" => USER_AGENT,
      "Cookie"     => @cookie,
    }
  end

  def xhr_headers(uri_path : String)
    HTTP::Headers{
      "Referer"          => full_path(uri_path),
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "User-Agent"       => USER_AGENT,
      "Cookie"           => @cookie,
    }
  end

  def http_client
    HTTP::Client.new(@hostname, tls: !self.insecure?)
  end

  ###

  def save_page(href : String, path : String,
                http_client : HTTP::Client = self.http_client) : String
    if @seedtype.in?(2, 4)
      raise "can not download page from this seed type"
    end

    http_client.get(href, headers: headers(href)) do |res|
      raise "http error: #{res.status_code}" unless res.status.success?

      html = res.body_io.tap(&.set_encoding(@encoding, invalid: :skip)).gets_to_end
      html = html.sub(/#{@encoding}|gb2312/i, "utf-8") unless @encoding == "UTF-8"

      html.tap do |data|
        File.write(path, data)
      rescue ex
        Log.error { "can not save file #{path}: #{ex.message}" }
      end
    end
  end

  def load_page(href : String, path : String,
                stale : Time = Time.utc - 1.days) : String
    Rmutil.still_fresh?(path, stale) ? File.read(path) : save_page(href, path)
  end

  ###

  def book_save_dir
    "#{ROOT_DIR}/wnbook/#{@hostname}"
  end

  def chap_save_dir(bid : Int32 | String)
    "#{ROOT_DIR}/wnchap/#{@hostname}/#{bid}"
  end

  #######

  CONF_DIR = "var/_conf/globs"

  class_getter mapping : Hash(String, String) do
    Hash(String, String).from File.read("#{CONF}/meta/mapping.yml")
  end

  CACHED = {} of String => self

  def self.load!(sname : String)
    CACHED[sname] ||= from_yaml(File.read("#{CONF_DIR}/#{sname}.yml"))
  end

  def self.from_host!(host : String)
    load!(self.mapping[host])
  end

  def self.from_link!(link : String)
    self.from_host!(URI.parse(link).host.as(String))
  end

  ######

  def self.full_book_link(sname : String, s_bid : Int32 | String)
    conf = load!(sname)
    conf.full_path(conf.make_book_path(s_bid))
  end

  def self.full_cata_link(sname : String, s_bid : Int32 | String)
    conf = load!(sname)
    conf.full_path(conf.make_cata_path(s_bid))
  end

  def self.full_chap_link(sname : String, s_bid : Int32 | String, s_cid : Int32 | String)
    conf = load!(sname)
    href = conf.make_chap_path(s_bid, s_cid)
    conf.full_path(href)
  end
end
