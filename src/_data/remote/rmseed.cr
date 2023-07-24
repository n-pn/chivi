require "http/client"
require "./_conf"

class Rmseed
  getter conf : Rmconf

  def self.from(hostname : String)
    new(Rmconf.load!(hostname))
  end

  def initialize(@conf)
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

  def save_page(href : String, save_to : String,
                http_client : HTTP::Client = make_client) : Nil
    Log.debug { "- Fetching: #{@conf.hostname}#{href}" }

    http_client.get(href, headers: headers(href)) do |res|
      unless res.status.success?
        Log.error { res.body_io.gets_to_end }
        raise "http error: #{res.status_code}"
      end

      res.body_io.set_encoding(@conf.encoding, invalid: :skip)
      html = res.body_io.gets_to_end
      html = html.sub(/#{@conf.encoding}|gb2312/i, "utf-8") unless @conf.encoding == "UTF-8"
      File.write(save_to, html)
    end
  end

  def read_page(href : String, path : String,
                stale : Time = Time.utc - 12.hours) : String
    save_page(href, path) unless Rmutil.still_fresh?(path, stale)
    File.read(path)
  end

  def get_mbid(ttl = 12.hours) : String
    html = read_page(@conf.mbid_path, @conf.mbid_file_path, stale: Time.utc - ttl)
    page = Rmpage.new(html)

    @conf.extract_bid(page.get!(@conf.mbid_elem, "href"))
  end
end

# test = Rmseed.new("www.hetushu.com")
# puts test.book_path(1000), test.book_file_path(1000)
# puts test.get_mbid
