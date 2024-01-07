require "json"
require "../../_util/http_util"

struct SP::BdAuth
  # WEB_URL = "https://fetch.nipin.workers.dev?q=https://fanyi.baidu.com"
  WEB_URL = "https://fanyi.baidu.com"
  WEB_URI = URI.parse(WEB_URL)

  getter token : String = ""
  getter gtk : String = ""
  getter cookie : String = ""

  def initialize
    @cookie = HttpUtil.make_client(WEB_URI).get("/", &.headers["Set-Cookie"])

    headers = HttpUtil.make_headers(WEB_URL, cookie: @cookie)
    res_body = HttpUtil.make_client(WEB_URI).get("/", headers: headers, &.body_io.gets_to_end)

    @token = res_body.match!(/token: '(.+)'/)[1]
    @gtk = res_body.match!(/window.gtk = ["'](.+)['"]/)[1]
  end

  def sign_query(query : String)
    chars = query.each_grapheme.to_a

    if chars.size > 30
      query = String.build do |io|
        chars.first(10).join(io)
        chars[chars.size // 2 - 5, 10].join(io)
        chars.last(10).join(io)
      end
    end

    m, s = @gtk.split('.', 2).map(&.to_u32)

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

  def form(query : String, tl = "vie")
    URI::Params.build do |form|
      form.add "query", query
      form.add "from", "zh"
      form.add "to", tl
      form.add "token", @token
      form.add "sign", sign_query(query)
      form.add "domain", "common"
      form.add "simple_means_flag", "3"
    end
  end

  def post_form(path : String, form : String)
    headers = HttpUtil.make_headers(WEB_URL,
      cookie: @cookie,
      content_type: "application/x-www-form-urlencoded"
    )

    client = HttpUtil.make_client(WEB_URI)
    client.post(path, headers: headers, body: form).body
  end

  class_getter alive : self { new }

  def self.reset!
    @@alive = nil
  end
end
