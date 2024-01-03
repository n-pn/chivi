require "json"
require "http/client"

module SP::BdUtil
  WEB_API = "https://fanyi.baidu.com"

  def self.reset_auth!
    @@cookie = nil
    @@auth = nil
  end

  class_getter cookie : String { HTTP::Client.get(WEB_API, &.headers["Set-Cookie"]) }

  def self.gen_headers(content_type = "application/x-www-form-urlencoded")
    HTTP::Headers{
      "Origin"       => WEB_API,
      "Referer"      => WEB_API,
      "User-Agent"   => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0",
      "Content-Type" => content_type,
      "Cookie"       => self.cookie,
    }
  end

  record Auth, token : String, gtk : String

  class_getter auth : Auth do
    HTTP::Client.get(WEB_API, headers: gen_headers) do |res|
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
