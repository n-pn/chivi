require "./ms_util"

module SP::MsTran
  def self.free_translate(input : Array(String), token : String = "",
                          sl : String = "zh", tl : String = "vi")
    token = MsUtil.free_token if token.empty?
    headers = MsUtil.bearer_headers(token)
    self.call_api(input, headers, sl: sl, tl: tl)
  rescue ex
    Log.warn { ex }
    MsUtil.free_until = Time.utc
    self.translate(input, sl: sl, tl: tl)
  end

  def self.translate(input : Array(String), sl : String = "zh", tl : String = "vi")
    raise "no more available client" unless key_data = MsUtil.sub_keys.last?
    headers = MsUtil.subkey_headers(*key_data)
    self.call_api(input, headers, sl: sl, tl: tl)
  rescue ex
    Log.warn { ex.message }
    raise ex unless MsUtil.sub_keys.pop?
    self.translate(input, sl: sl, tl: tl)
  end

  API = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&textType=plain"

  def self.call_api(input : Array(String),
                    headers : HTTP::Headers,
                    sl : String = "zh", tl : String = "vi")
    sl = "zh-Hans" if sl == "zh"

    uri = URI.parse("#{API}&from=#{sl}&to=#{tl}")

    body = input.map { |text| {text: text} }.to_json

    client = HTTP::Client.new(uri)
    client.connect_timeout = 2.seconds
    client.read_timeout = 5.seconds

    client.post(uri.request_target, headers: headers, body: body) do |res|
      raise res.body unless res.status.success?
      output = Array(Tran).from_json(res.body_io)
      output.map(&.translations.map(&.text))
    end
  end

  struct Tran
    record Text, text : String do
      include JSON::Serializable
    end

    include JSON::Serializable
    getter translations : Array(Text)
  end
end

# test = "能源、表情".split("、")
# puts SP::Btran.translate(test).to_pretty_json
# puts SP::Btran.lookup(["in", "out"]).to_pretty_json
