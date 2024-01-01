require "./ms_util"

module SP::MsDict
  ####

  def self.lookup(words : Array(String), sl : String = "zh", tl : String = "vi")
    raise "no more available client" unless key_data = MsUtil.sub_keys.last?
    headers = MsUtil.subkey_headers(*key_data)
    self.call_api(headers, words, sl: sl, tl: tl)
  rescue ex
    Log.warn { ex }
    raise ex unless MsUtil.sub_keys.pop?
    self.lookup(words, sl: sl, tl: tl)
  end

  API = "https://api.cognitive.microsofttranslator.com/dictionary/lookup?api-version=3.0&textType=plain"

  def self.call_api(headers : HTTP::Headers, ztext : Enumerable(String), sl : String = "zh", tl : String = "en")
    sl = "zh-Hans" if sl == "zh"
    url = "#{API}&from=#{sl}&to=#{tl}"
    body = ztext.map { |x| {text: x} }.to_json

    HTTP::Client.post(url, headers: headers, body: body) do |res|
      raise res.body unless res.status.success?
      Array(Term).from_json(res.body)
    end
  end

  class Term
    include JSON::Serializable

    @[JSON::Field(key: "normalizedSource")]
    getter normalized_source : String

    @[JSON::Field(key: "displaySource")]
    getter display_source : String

    getter translations : Array(Tran)

    class Tran
      include JSON::Serializable

      @[JSON::Field(key: "normalizedTarget")]
      getter normalized_target : String

      @[JSON::Field(key: "displayTarget")]
      getter display_target : String

      @[JSON::Field(key: "posTag")]
      getter pos_tag : String

      getter confidence : Float32

      @[JSON::Field(key: "prefixWord")]
      getter prefix_word : String

      @[JSON::Field(key: "backTranslations")]
      getter back_translations : Array(Back)

      class Back
        include JSON::Serializable

        @[JSON::Field(key: "normalizedText")]
        getter normalized_text : String

        @[JSON::Field(key: "displayText")]
        getter display_text : String

        @[JSON::Field(key: "numExamples")]
        getter num_examples : Int32

        @[JSON::Field(key: "frequencyCount")]
        getter frequency_count : Int32
      end
    end
  end
end

# test = "能源、表情".split("、")
# puts SP::Btran.translate(test).to_pretty_json
# puts SP::Btran.lookup(["in", "out"]).to_pretty_json
