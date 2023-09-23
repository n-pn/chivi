require "json"
require "uuid"
require "http/client"

module SP::Btran
  extend self
  API = "https://api.cognitive.microsofttranslator.com"

  struct TranlateOutput
    record Entry, text : String do
      include JSON::Serializable
    end

    include JSON::Serializable
    getter translations : Array(Entry)
  end

  def call_tran_api(headers : HTTP::Headers, input : Array(String),
                    sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    sl = "zh-Hans" if sl == "zh"
    href = "/translate?from=#{sl}&to=#{tl}&api-version=3.0&textType=plain"
    body = input.map { |x| {text: no_cap ? "*," + x : x} }.to_json

    client = HTTP::Client.new(URI.parse(API))
    client.connect_timeout = 2
    client.read_timeout = 5

    client.post(href, headers: headers, body: body) do |res|
      raise res.body unless res.status.success?
      output = Array(TranlateOutput).from_json(res.body_io)
      raise "size mismatch" if output.size != input.size

      output = output.map(&.translations.first.text)
      no_cap ? output.map!(&.sub(/^[\P{L}]+/, "")) : output
    end
  end

  class LookupOutput
    include JSON::Serializable

    @[JSON::Field(key: "normalizedSource")]
    getter normalized_source : String

    @[JSON::Field(key: "displaySource")]
    getter display_source : String

    getter translations : Array(Translation)

    class Translation
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

      # @[JSON::Field(key: "backTranslations")]
      # getter back_translations : Array(BackTranslation)

      # class BackTranslation
      #   include JSON::Serializable

      #   @[JSON::Field(key: "normalizedText")]
      #   getter normalized_text : String

      #   @[JSON::Field(key: "displayText")]
      #   getter display_text : String

      #   @[JSON::Field(key: "numExamples")]
      #   getter num_examples : Int32

      #   @[JSON::Field(key: "frequencyCount")]
      #   getter frequency_count : Int32
      # end
    end
  end

  def call_dict_api(headers : HTTP::Headers, terms : Enumerable(String), sl : String = "zh", tl : String = "en")
    sl = "zh-Hans" if sl == "zh"
    url = "#{API}/dictionary/lookup?from=#{sl}&to=#{tl}&api-version=3.0&textType=plain"
    body = terms.map { |x| {text: x} }.to_json

    HTTP::Client.post(url, headers: headers, body: body) do |res|
      raise res.body unless res.status.success?
      Array(LookupOutput).from_json(res.body)
    end
  end

  def subkey_headers(key : String, region : String = "")
    headers = HTTP::Headers{
      "Ocp-Apim-Subscription-Key" => key,
      "Content-type"              => "application/json",
      "X-ClientTraceId"           => UUID.random.to_s,
    }

    headers["Ocp-Apim-Subscription-Region"] = region unless region.blank?
    headers
  end

  def bearer_headers(key : String)
    HTTP::Headers{
      "Authorization"   => "Bearer #{key}",
      "Content-type"    => "application/json",
      "X-ClientTraceId" => UUID.random.to_s,
    }
  end

  @@keys : Array({String, String}) = read_keys({{ read_file("#{__DIR__}/btran.tsv") }})

  def read_keys(input : String)
    input.lines.compact_map do |line|
      args = line.split('\t')
      {args[0], args[1]? || ""} if args.size > 1 && args[2]? == "work"
    end
  end

  ####

  def translate(input : Array(String), sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    raise "no more available client" unless key_data = @@keys.last?
    headers = subkey_headers(*key_data)
    call_tran_api(headers, input, sl: sl, tl: tl, no_cap: no_cap)
  rescue ex
    Log.warn { ex }
    raise ex unless @@keys.pop?
    translate(input, sl: sl, tl: tl, no_cap: no_cap)
  end

  def self.free_translate(input : Array(String), sl : String = "zh", tl : String = "vi", no_cap : Bool = false) : Array(String)
    headers = bearer_headers(self.free_token)
    call_tran_api(headers, input, sl: sl, tl: tl, no_cap: no_cap)
  rescue ex
    Log.warn { ex }
    @@free_token = nil
    translate(input, sl: sl, tl: tl, no_cap: no_cap)
  end

  def self.free_translate(text : String, sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    free_translate([text], sl: sl, tl: tl, no_cap: no_cap)
  end

  @@free_token : String? = nil
  @@free_until = Time.utc

  def self.free_token : String
    @@free_token.try { |token| return token if @@free_until >= Time.utc }

    client = HTTP::Client.new(URI.parse("https://edge.microsoft.com"))
    client.connect_timeout = 2
    client.read_timeout = 5

    @@free_until = Time.utc + 5.minutes
    @@free_token = client.get("/translate/auth", &.body_io.gets_to_end)
  end

  def lookup(input : Array(String), sl : String = "zh", tl : String = "vi")
    raise "no more available client" unless key_data = @@keys.last?
    headers = subkey_headers(*key_data)
    call_dict_api(headers, input, sl: sl, tl: tl)
  rescue ex
    Log.warn { ex }
    raise ex unless @@keys.pop?
    lookup(input, sl: sl, tl: tl)
  end
end

# test = "能源、表情".split("、")
# puts SP::Btran.translate(test).to_pretty_json
# puts SP::Btran.lookup(["in", "out"]).to_pretty_json

puts SP::Btran.free_translate(["朱铁崖", "卢修斯", "同文"], no_cap: true)
