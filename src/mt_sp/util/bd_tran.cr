require "json"
require "colorize"

require "./bd_util"
require "../../_util/http_util"

module SP::BdTran
  WEB_URL = "https://fanyi.baidu.com"
  WEB_URI = URI.parse(WEB_URL)

  def self.api_translate(query : Array(String), tl = "vie", retry : Int32 = 3)
    api_translate(query.join('\n'), tl: tl, retry: retry)
  end

  def self.api_translate(query : String, tl = "vie", retry : Int32 = 3)
    body = {
      query: query, from: "zh", to: tl,
      reference: "", corpusIds: [] of Int32, domain: "common",
      qcSettings: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"],
    }.to_json

    headers = HttpUtil.gen_headers(WEB_URL, type: :json)

    retry.times do |i|
      proxy = HttpProxy.pick_one
      client = HttpUtil.http_client(WEB_URI)

      res = client.post("/ait/text/translate", headers: headers, body: body)
      res_body = res.body

      if res.status.success? && (res_json = ApiData.parse(res_body))
        return res_json.data.map(&.dst)
      end

      Log.warn { res.body.colorize.magenta }
      sleep (i + 1).seconds
      proxy.try(&.rotate_ip!)
    rescue ex
      case ex.message || ""
      when .includes?("Connection refused")
        proxy = HttpProxy.all_entries.pop?
        Log.info { "removing #{proxy.host}:#{proxy.port}" } if proxy

        raise ex
      else
        Log.warn { ex.message.colorize.red }
      end
    end

    raise "tried #{retry} with error, aborting!"
  end

  struct ApiData
    include JSON::Serializable

    @[JSON::Field(root: "list")]
    getter data : Array(Item)

    struct Item
      include JSON::Serializable
      getter dst : String
    end

    def self.parse(input : String)
      input.each_line do |line|
        next unless line.includes?("event\":\"Translating\"")
        return from_json(line.lchop("data: "))
      end

      nil
    end
  end

  def self.web_translate(ztext : String, tl = "vie", retry : Bool = true)
    auth = BdAuth.alive
    form = auth.form(ztext, tl)

    while retry
      res_body = BdAuth.alive.post_form("/v2transapi", form: form)

      if res_body.includes?("trans_result")
        return WebData.from_json(res_body).trans_result.map(&.dst)
      end

      if retry
        BdAuth.reset!
        retry = false
      else
        error = NamedTuple(errmsg: String).from_json(res_body)
        raise error[:errmsg]
      end
    end
  end

  struct WebData
    include JSON::Serializable

    @[JSON::Field(root: "data")]
    getter trans_result : Array(Item)

    struct Item
      include JSON::Serializable
      getter dst : String
    end
  end

  # puts api_translate "我的女儿"
  # puts web_translate "数百名示威者聚集"
end
