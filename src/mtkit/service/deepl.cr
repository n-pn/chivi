require "json"
require "uuid"
require "http/client"

class TL::Deepl
  FREE_API = "https://api-free.deepl.com"
  PRO_API  = "https://api.deepl.com"

  getter key : String

  @headers : HTTP::Headers
  @client : HTTP::Client

  def initialize(@key : String, free : Bool = true)
    @headers = HTTP::Headers{
      "Authorization" => "DeepL-Auth-Key #{key}",
      "Content-Type"  => "application/x-www-form-urlencoded",
    }
    @client = HTTP::Client.new(URI.parse(free ? FREE_API : PRO_API))
  end

  def translate(terms : Enumerable(String), no_cap : Bool = false)
    body = String.build do |str|
      terms.each_with_index do |term, i|
        str << '&' if i > 0
        str << "text="
        str << "*," if no_cap
        URI.encode_path(str, term)
      end

      str << "&source_lang=ZH&target_lang=EN&split_sentences=1"
    end

    res = @client.post("/v2/translate", headers: @headers, body: body)
    raise res.body unless res.status.success?

    output = Array(TranslateResult).from_json(res.body, root: "translations")
    raise "size mismatch" if output.size != terms.size

    output.map_with_index do |entry, i|
      term = terms[i]
      data = no_cap ? entry.text.sub(/^\*,\s/, "") : entry.text
      {term, data}
    end
  end

  class TranslateResult
    include JSON::Serializable

    getter text : String
    getter detected_source_language : String?
  end

  ####

  class_getter clients : Array(Deepl) = begin
    lines = {{ read_file("#{__DIR__}/deepl.tsv").split('\n') }}

    lines.each_with_object([] of Deepl) do |line, list|
      args = line.split('\t')
      next unless key = args[0]?
      next if args[2]? == "dead"

      list << Deepl.new(key, free: args[1]? != "pro")
    end
  end

  def self.translate(terms : Enumerable(String), no_cap : Bool = false)
    raise "no more available client" unless client = @@clients.sample
    translate(client, terms, no_cap: no_cap)
  end

  def self.translate(client : Deepl, terms : Enumerable(String), no_cap : Bool = false)
    client.translate(terms, no_cap: no_cap)
  rescue err
    Log.warn { "error using deepl translation: #{err.message}" }

    if err.message.try(&.starts_with?("size mismatch"))
      translate(client, terms, no_cap: no_cap)
    else
      @@clients.reject!(&.== client)
      translate(terms, no_cap: no_cap)
    end
  end
end

# test = "能源、表情".split("、")
# TL::Deepl.clients.each do |client|
#   puts TL::Deepl.translate(client, test).to_pretty_json
# rescue err
#   puts err
#   puts client.key
# end
