require "log"
require "yaml"
require "http/client"

require "./rmpage"
require "./rmutil"

# Log.setup_from_env

class Rmhost
  include YAML::Serializable

  property hostname : String
  property encoding = "GBK"
  property? insecure = false
  property cookie = ""

  property time_fmt = "%F %T"
  property? full_tz : Bool { time_fmt == "%F %T" }

  # @[YAML::Field(ignore: true)]
  getter base_url : String { @insecure ? "http://#{@hostname}" : "https://#{@hostname}" }

  ####

  property seedname : String
  property seedtype : Int32 = 0
  property seedrank : Int32 = 0

  ####

  property book_id_re = "(\\d+)\\D*$"
  @[YAML::Field(ignore: true)]
  getter book_id_regex : Regex { Regex.new(@book_id_re) }

  property chap_id_re = "(\\d+)\\D*$"
  @[YAML::Field(ignore: true)]
  getter chap_id_regex : Regex { Regex.new(@chap_id_re) }

  property bid_cid_re = "(?<bid>\\d+)/(?<cid>\\d+)\\D*$"
  @[YAML::Field(ignore: true)]
  getter bid_cid_regex : Regex { Regex.new(@bid_cid_re) }

  ###

  property mbid_path = "/"
  property mbid_elem = "#newscontent > .r > ul > li:first-child > .s2 > a"

  ###

  property book_path = "/book/%{bid}/"
  property book_type = ""

  property book_btitle = {"head > meta[property=\"og:novel:book_name\"]", "content"}
  property book_author = {"head > meta[property=\"og:novel:author\"]", "content"}

  property book_latest = {"head > meta[property=\"og:novel:latest_chapter_url\"]", "content"}
  property book_update : {String, String} | Nil = {"head > meta[property=\"og:novel:update_time\"]", "content"}
  property book_status : {String, String} | Nil = {"head > meta[property=\"og:novel:status\"]", "content"}

  property book_cover = {"head > meta[property=\"og:image\"]", "content"}
  property book_intro = {"head > meta[property=\"og:description\"]", "content"}
  property book_genre = {"head > meta[property=\"og:novel:category\"]", "content"}
  property book_xtags : {String, String} | Nil = nil
  ###

  property cata_path = "/book/%{bid}/"
  property cata_type = "subdiv"
  property cata_elem = "#list > dl"

  property cata_latest = {"head > meta[property=\"og:novel:status\"]", "content"}
  property cata_update : {String, String} | Nil = {"head > meta[property=\"og:novel:update_time\"]", "content"}
  property cata_status : {String, String} | Nil = {"head > meta[property=\"og:novel:status\"]", "content"}

  ###

  property chap_path = "/book/%{bid}/%{cid}.html"
  property chap_type = ""

  property chap_name = "h1"
  property chap_body = "#content"

  property chap_body_scrub : String? = nil
  @[YAML::Field(ignore: true)]
  getter chap_scrub_re : Regex { Regex.new(@chap_body_scrub || ".") }

  ###

  def active?
    @seedtype < 2
  end

  def dead?
    @seedtype > 3
  end

  def full_url(path : String = "/")
    "#{self.base_url}#{path}"
  end

  ###

  def extract_bid(href : String)
    if match = self.book_id_regex.match(href)
      match[1]
    else
      # puts [@seedname, @hostname, @book_id_re].colorize.red
      raise "can't extract bid from [#{href}]"
    end
  end

  def extract_cid(href : String) : String
    if match = self.chap_id_regex.match(href)
      match[1]
    else
      raise "can't extract cid from [#{href}]"
    end
  end

  def extract_ids(href : String)
    match = self.bid_cid_regex.match!(href)
    {match["bid"], match["cid"]}
  end

  def parse_time(date : String)
    Rmutil.parse_time(date, @time_fmt, self.full_tz?)
  end

  ####

  KEEP_DIR = "var/.keep"
  BMID_DIR = "#{KEEP_DIR}/_index/%{name}.htm"

  def mbid_file
    "#{KEEP_DIR}/_index/#{seedname}.htm"
  end

  def get_max_bid(tspan = 12.hours)
    html = self.load_page(@mbid_path, self.mbid_file, stale: Time.utc - tspan)
    href = Rmpage.new(html).get!(@mbid_elem, "href")
    extract_bid(href).to_i
  end

  ###

  @[AlwaysInline]
  private def gen_div(sn_id : Int32 | String)
    (sn_id.to_i // 1000) rescue 0
  end

  ###

  def book_href(bid : Int32 | String)
    @book_path % {div: gen_div(bid), bid: bid}
  end

  def stem_href(sn_id : Int32 | String)
    @cata_path % {div: gen_div(sn_id), bid: sn_id}
  end

  def chap_href(sn_id : Int32 | String, sc_id : Int32 | String)
    @chap_path % {div: gen_div(sn_id), bid: sn_id, cid: sc_id}
  end

  ###

  def book_url(sn_id : Int32 | String)
    self.full_url(self.book_href(sn_id))
  end

  def stem_url(sn_id : Int32 | String)
    self.full_url(self.stem_href(sn_id))
  end

  def chap_url(sn_id : Int32 | String, sc_id : Int32 | String)
    self.full_url(self.chap_href(sn_id, sc_id))
  end

  ###

  def book_dir
    "#{KEEP_DIR}/rmbook/#{@hostname}"
  end

  def chap_dir(sn_id : Int32 | String)
    "#{KEEP_DIR}/rmchap/#{@hostname}/#{sn_id}"
  end

  ###

  def book_file(sn_id : Int32 | String)
    "#{KEEP_DIR}/rmbook/#{@hostname}/#{sn_id}.htm"
  end

  def stem_file(sn_id : Int32 | String)
    file_path = self.book_file(sn_id)
    @book_path == @cata_path ? file_path : file_path.sub(".htm", "-cata.htm")
  end

  def chap_file(sn_id : Int32 | String, sc_id : Int32 | String)
    "#{KEEP_DIR}/rmchap/#{hostname}/#{sn_id}/#{sc_id}.htm"
  end

  ###

  def get_headers(uri_path : String)
    Rmutil.get_headers(full_url(uri_path), @cookie)
  end

  def xhr_headers(uri_path : String)
    Rmutil.xhr_headers(full_url(uri_path), @cookie)
  end

  def http_client
    HTTP::Client.new(@hostname, tls: !self.insecure?)
  end

  ###

  def save_page(href : String, save_path : String,
                http_client : HTTP::Client = self.http_client) : String
    if @seedtype.in?(2, 4)
      raise "can not download page from this seed type"
    end

    http_client.get(href, headers: self.get_headers(href)) do |res|
      if res.status.success?
        html = res.body_io.tap(&.set_encoding(@encoding, invalid: :skip)).gets_to_end
        html = html.sub(/#{@encoding}|gb2312/i, "utf-8") unless @encoding == "UTF-8"
        html.tap { |data| File.write(save_path, data) rescue "can't write to file!" }
      elsif res.status == :not_found
        File.write("#{save_path}.404", res.body_io.gets_to_end)
        raise "404 not found!"
      else
        raise "http error: #{res.status_code}"
      end
    end
  end

  def load_page(href : String, save_path : String,
                stale : Time = Time.utc - 30.days) : String
    Rmutil.still_fresh?(save_path, stale) ? File.read(save_path) : save_page(href, save_path)
  end

  ###

  def get_all!(queue : Array({String, String, Int32}), w_size = 6)
    q_size = queue.size
    w_size = q_size if w_size > w_size

    workers = Channel({String, String, Int32}).new(q_size)
    results = Channel(String).new(w_size)

    spawn do
      queue.each { |entry| workers.send(entry) }
    end

    w_size.times do
      spawn do
        loop do
          href, save_path, idx = workers.receive
          self.save_page(href: href, save_path: save_path)
          results.send "- <#{idx}/#{q_size}> #{href.colorize.blue} saved!"
        rescue err
          results.send "- <#{idx}/#{q_size}> #{err.message.colorize.red}"
        end
      end
    end

    q_size.times { puts(results.receive) }
  end

  #######

  CONF_DIR = "var/_conf/hosts"
  Dir.mkdir_p(CONF_DIR)

  class_getter mapping : Hash(String, String) do
    Hash(String, String).from_yaml File.read("#{CONF_DIR}/../hosts.yml")
  end

  def self.is_remote?(sname : String)
    mapping.has_key?(sname)
  end

  CACHED = {} of String => self

  def self.from_host!(host : String)
    CACHED[host] ||= self.from_yaml(File.read("#{CONF_DIR}/#{host}.yml"))
  end

  def self.from_link!(link : String)
    self.from_host!(URI.parse(link).host.as(String))
  end

  def self.from_name!(sname : String)
    self.from_host!(self.mapping[sname])
  end

  ######

  def self.book_url(sname : String, sn_id : Int32 | String)
    self.from_name!(sname).book_url(sn_id)
  end

  def self.stem_url(sname : String, sn_id : Int32 | String)
    self.from_name!(sname).stem_url(sn_id)
  end

  def self.chap_url(sname : String, sn_id : Int32 | String, sc_id : Int32 | String)
    self.from_name!(sname).text_url(sn_id, sc_id)
  end
end
