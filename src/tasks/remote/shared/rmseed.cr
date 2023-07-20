require "yaml"
require "http/client"
require "./rmpage"

class Rmseed
  class Conf
    include YAML::Serializable

    getter seedname : String
    getter hostname : String

    getter? insecure = false
    getter encoding = "GBK"

    getter cookie = ""

    getter book_page_match = ""
    getter chap_page_match = ""

    getter mbid_link = ""
    getter mbid_save = ""
    getter mbid_elem = ""

    getter book_link = ""
    getter book_save = ""
  end

  getter conf : Conf

  getter book_page_re : Regex { Regex.new(@conf.book_page_match) }
  getter chap_page_re : Regex { Regex.new(@conf.chap_page_match) }

  CONF_DIR = "var/_conf/globs"
  SAVE_DIR = "/2tb/var.chivi/.keep"

  def initialize(hostname : String)
    @conf = Conf.from_yaml(File.read("#{CONF_DIR}/#{hostname}.yml"))
  end

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"

  def headers(uri_path : String)
    scheme = @conf.insecure? ? "http" : "https"

    HTTP::Headers{
      "Referer"    => "#{scheme}://#{@conf.hostname}#{uri_path}",
      "User-Agent" => USER_AGENT,
      "Cookie"     => @conf.cookie,
    }
  end

  def xhr_headers(uri_path : String)
    HTTP::Headers{
      "Referer"          => "https://#{@conf.hostname}#{uri_path}",
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "User-Agent"       => USER_AGENT,
      "Cookie"           => @conf.cookie,
    }
  end

  def make_client(tls = !@conf.insecure?)
    HTTP::Client.new(@conf.hostname, tls: tls)
  end

  def save_page(link_path : String, save_path : String,
                http_client : HTTP::Client = make_client) : Nil
    Log.debug { "- Fetching: #{@conf.hostname}#{link_path}" }

    http_client.get(link_path, headers: headers(link_path)) do |res|
      raise "http error: #{res.status_code}" unless res.status.success?

      res.body_io.set_encoding(@conf.encoding, invalid: :skip)
      html = res.body_io.gets_to_end
      html = html.sub(/#{@conf.encoding}|gb2312/i, "utf-8") unless @conf.encoding == "UTF-8"
      File.write(save_path, html)
    end
  end

  def read_page(link_path : String, save_path : String,
                too_old : Time = Time.utc - 12.hours) : String
    save_page(link_path, save_path) unless still_fresh?(save_path, too_old)
    File.read(save_path)
  end

  def still_fresh?(file_path : String, too_old : Time) : Bool
    File.info?(file_path).try(&.modification_time.> too_old) || false
  end

  def get_mbid(ttl = 12.hours) : String
    save_path = "#{SAVE_DIR}/latest/#{@conf.seedname}.htm"
    html = read_page(@conf.mbid_link, save_path, too_old: Time.utc - ttl)
    page = Rmpage.new(html)

    mbid_href = page.get!(@conf.mbid_elem, "href")
    book_page_re.match!(mbid_href)[1]
  end

  def book_link(bid : Int32)
    @conf.book_link % {bid: bid, div: bid // 1000}
  end

  def book_link(bid : String)
    @conf.book_link % {bid: bid}
  end

  def book_file(bid : Int32 | String)
    fname = @conf.book_save % {bid: bid}
    "#{SAVE_DIR}/wnbook/#{@conf.hostname}/#{fname}"
  end

  def cata_link(bid : Int32)
    @conf.cata_link % {bid: bid, div: bid // 1000}
  end

  def cata_link(bid : String)
    @conf.cata_link % {bid: bid}
  end

  def cata_file(bid : Int32 | String)
    fname = @conf.cata_save % {bid: bid}
    "#{SAVE_DIR}/wnbook/#{@conf.hostname}/#{fname}"
  end

  def chap_link(bid : Int32)
    @conf.chap_link % {bid: bid, div: bid // 1000}
  end

  def chap_link(bid : String)
    @conf.chap_link % {bid: bid}
  end

  def chap_file(bid : Int32 | String)
    fname = @conf.chap_save % {bid: bid}
    "#{SAVE_DIR}/wnchap/#{@conf.hostname}/#{fname}"
  end

  # def book_info(bid : Int32, ttl = 12.hours)
end

# test = Rmseed.new("www.hetushu.com")
# puts test.book_link(1000), test.book_file(1000)
# puts test.get_mbid
