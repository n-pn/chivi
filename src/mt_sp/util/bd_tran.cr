require "colorize"
require "./bd_util"

module SP::BdTran
  BD_WEB = "https://fetch.nipin.workers.dev?q=https://fanyi.baidu.com/v2transapi"

  def self.web_translate(ztext : String, sl = "zh", tl = "vie", retry : Bool = true)
    body = URI::Params.build do |form|
      form.add "query", ztext
      form.add "from", sl
      form.add "to", tl
      form.add "token", BdUtil.auth.token
      form.add "sign", BdUtil.sign_query(ztext)
      form.add "domain", "common"
      form.add "simple_means_flag", "3"
    end

    HTTP::Client.post(BD_WEB, headers: BdUtil.gen_headers, body: body) do |res|
      res_body = res.body_io.gets_to_end
      if res_body.includes?("trans_result")
        return WebData.from_json(res_body).trans_result.map(&.dst)
      end

      error = NamedTuple(errmsg: String).from_json(res_body)
      raise error[:errmsg] unless retry

      sleep 5.seconds
      BdUtil.reset_auth!
      web_translate(ztext, sl: sl, tl: tl, retry: false)
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

  # BD_API = "https://fetch.nipin.workers.dev?q=https://fanyi.baidu.com/ait/text/translate"
  BD_API = "https://fanyi.baidu.com/ait/text/translate"

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

      raise "invalid: #{input}"
    end
  end

  def self.api_translate(ztext : String, sl = "zh", tl = "vie")
    headers = BdUtil.gen_headers("application/json")

    body = {
      query: ztext, from: sl, to: tl,
      reference: "", corpusIds: [] of Int32, domain: "common",
      qcSettings: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"],
    }

    HTTP::Client.post(BD_API, headers: headers, body: body.to_json) do |res|
      body = res.body_io.gets_to_end
      raise res.body unless body.includes?("Translating")
      ApiData.parse(body).data.map(&.dst)
    end
  end

  # puts api_translate "我的女儿"
  # puts web_translate("数百名示威者聚集")
end
