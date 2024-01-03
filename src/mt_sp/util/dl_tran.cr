require "json"
require "uuid"
require "http/client"

class SP::DlTran
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

  def translate(terms : Enumerable(String),
                source = "ZH", target = "EN",
                no_cap : Bool = false)
    body = String.build do |str|
      terms.each_with_index do |term, i|
        str << '&' if i > 0
        str << "text="
        str << "*," if no_cap
        URI.encode_path(str, term)
      end

      str << "&source_lang=#{source}&target_lang=#{target}&split_sentences=1"
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

  struct TranslateResult
    include JSON::Serializable

    getter text : String
    # getter detected_source_language : String?
  end

  ####

  class_getter clients : Array(DlTran) = begin
    lines = {{ read_file("#{__DIR__}/deepl.tsv").split('\n') }}

    lines.each_with_object([] of DlTran) do |line, list|
      next if line.blank?
      auth_key = line.split('\t', 2).first

      next if auth_key.starts_with?('#')
      list << DlTran.new(auth_key, free: auth_key.ends_with?(":fx"))
    end
  end

  def self.translate(terms : Enumerable(String),
                     source = "zh", target = "en",
                     no_cap : Bool = false)
    raise "no more available keys" unless client = @@clients.first?
    translate(client, terms, source: source, target: target, no_cap: no_cap)
  end

  def self.translate(client : DlTran, terms : Enumerable(String),
                     source = "zh", target = "en",
                     no_cap : Bool = false)
    client.translate(terms, source: source, target: target, no_cap: no_cap)
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
# puts TL::Deepl.translate(test, no_cap: true).to_pretty_json
