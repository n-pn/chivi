require "colorize"
require "./bd_util"
require "../data/v_cache"

module SP::BdTran
  API_PATH    = "/ait/text/translate"
  API_HEADERS = BdUtil.gen_headers("application/json")

  def self.api_translate(input : Array(String), tl : String = "vie", retry = true, cache = true)
    return api_translate(input.join('\n'), tl: tl, retry: retry, cache: cache) unless cache

    output, blanks = VCache.get_val(VCache::Obj.for_bd(tl), input)
    return output if blanks.empty?

    ztext = blanks.join('\n') { |idx| input[idx] }
    trans = api_translate(ztext, tl: tl, retry: retry, cache: cache)
    trans.each_with_index { |tran, idx| output[blanks[idx]] = tran }

    output
  end

  def self.api_translate(ztext : String, tl = "vie", retry : Bool = true, cache : Bool = true)
    body = {
      query: ztext, from: "zh", to: tl,
      reference: "", corpusIds: [] of Int32, domain: "common",
      qcSettings: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"],
    }.to_json

    error = (1..).each do |i|
      proxy = RotateProxy.all_entries.last?
      res_body = BdUtil.client(proxy).post(API_PATH, headers: API_HEADERS, body: body, &.body_io.gets_to_end)

      if res_body.includes?("Translating")
        trans = ApiData.parse(res_body).data.map(&.dst)
        cache_result!(ztext, trans, tl: tl) if cache
        return trans
      end

      break res_body unless proxy || retry
      Log.warn { res_body.colorize.red }

      sleep i.seconds
      proxy.try(&.change_ip!)
    rescue ex
      RotateProxy.all_entries.pop? if ex.message.try(&.includes?("Connection refused"))
    end

    raise error
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

      raise "invalid: #{input}"
    end
  end

  def self.web_translate(ztext : String, tl = "vie", retry : Bool = true)
    tl = "vie" if tl == "vi"

    body = URI::Params.build do |form|
      form.add "query", ztext
      form.add "from", "zh"
      form.add "to", tl
      form.add "token", BdUtil.auth.token
      form.add "sign", BdUtil.sign_query(ztext)
      form.add "domain", "common"
      form.add "simple_means_flag", "3"
    end

    headers = BdUtil.gen_headers("application/x-www-form-urlencoded")

    BdUtil.client(true).post("/v2transapi", headers: headers, body: body) do |res|
      res_body = res.body_io.gets_to_end

      if res_body.includes?("trans_result")
        trans = WebData.from_json(res_body).trans_result.map(&.dst)
        cache_result!(ztext, trans, tl)
        trans
      elsif retry
        BdUtil.reset_auth!
        web_translate(ztext, tl: tl, retry: false)
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

  def self.cache_result!(ztext : String, trans : Array(String), tl = "vie")
    spawn VCache.cache!(obj: VCache::Obj.for_bd(tl), vals: trans, raws: ztext.lines)
  end

  # puts api_translate "我的女儿"
  # puts web_translate "数百名示威者聚集"
end
