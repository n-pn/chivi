require "json"
require "uuid"
require "http/client"

class SP::Btran
  ENDPOINT = "https://api.cognitive.microsofttranslator.com"

  @headers : HTTP::Headers
  @client : HTTP::Client

  def initialize(key : String, region : String? = "southeastasia")
    @headers = HTTP::Headers{
      "Ocp-Apim-Subscription-Key" => key,
      "Content-type"              => "application/json",
    }

    @headers["Ocp-Apim-Subscription-Region"] = region if region && !region.empty?
    @client = HTTP::Client.new(URI.parse(ENDPOINT))
  end

  class TranslateResult
    include JSON::Serializable

    getter text : String
    getter to : String?
  end

  def translate(terms : Enumerable(String), lang = "vi", no_cap : Bool = false)
    @headers["X-ClientTraceId"] = UUID.random.to_s

    params = URI::Params.build do |form|
      form.add "api-version", "3.0"
      form.add "from", "zh-Hans"
      form.add "to", lang
    end

    body = terms.map { |x| {text: no_cap ? "*," + x : x} }.to_json

    url = "/translate?" + params.to_s
    res = @client.post(url, headers: @headers, body: body)
    raise res.body unless res.status.success?

    output = Array(NamedTuple(translations: Array(TranslateResult))).from_json(res.body)

    raise "size mismatch" if output.size != terms.size

    output.map_with_index do |entry, i|
      term = terms[i]

      data = entry[:translations].map do |item|
        text = item.text
        no_cap ? text.sub(/^\*,\s/, "") : text
      end

      {term, data.join('\t')}
    end
  end

  def lookup(terms : Enumerable(String))
    @headers["X-ClientTraceId"] = UUID.random.to_s

    params = URI::Params.build do |form|
      form.add "api-version", "3.0"
      form.add "from", "en"
      form.add "to", ""
    end

    body = terms.map { |x| {Text: x} }.to_json

    url = "/dictionary/lookup?" + params.to_s
    res = @client.post(url, headers: @headers, body: body)
    raise res.body unless res.status.success?

    Array(LookupResult).from_json(res.body)
  end

  class LookupResult
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

      @[JSON::Field(key: "backTranslations")]
      getter back_translations : Array(BackTranslation)

      class BackTranslation
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

  ####

  @@clients : Array(self) = begin
    lines = {{ read_file("#{__DIR__}/btran.tsv").split('\n') }}

    lines.each_with_object([] of Btran) do |line, list|
      args = line.split('\t')
      next unless key = args[0]?
      next unless args[2]? == "work"
      list << Btran.new(key, args[1]?)
    end
  end

  def self.translate(terms : Enumerable(String), lang = "vi", no_cap : Bool = false)
    raise "no more available client" unless client = @@clients.sample
    translate(client, terms, lang: lang, no_cap: no_cap)
  end

  def self.translate(client : self, terms : Enumerable(String), lang : String, no_cap : Bool)
    client.translate(terms, lang: lang, no_cap: no_cap)
  rescue err
    Log.warn { "error using bing translation: #{err.message}" }

    if err.message.try(&.starts_with?("size mismatch"))
      translate(client, terms, lang: lang, no_cap: no_cap)
    else
      @@clients.reject!(&.== client)
      translate(terms, lang: lang, no_cap: no_cap)
    end
  end

  def self.lookup(terms : Enumerable(String))
    raise "no more available client" unless client = @@clients.sample
    lookup(client, terms)
  end

  def self.lookup(client : self, terms : Enumerable(String))
    client.lookup(terms)
  rescue err
    Log.warn { "error using bing translation: #{err.message}" }

    if err.message.try(&.starts_with?("size mismatch"))
      lookup(client, terms)
    else
      @@clients.reject!(&.== client)
      lookup(terms)
    end
  end
end

# test = "能源、表情".split("、")
# puts SP::Btran.translate(test).to_pretty_json
# puts SP::Btran.lookup(["in", "out"]).to_pretty_json
