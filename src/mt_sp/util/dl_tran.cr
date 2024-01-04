require "json"
require "uuid"
require "http/client"

module SP::DlTran
  class_getter api_keys : Array(String) do
    {{ read_file("#{__DIR__}/dl_auth.tsv") }}.lines.compact_map do |line|
      next if line.blank? || line.starts_with?('#')
      line.split('\t', 2).first
    end
  end

  def self.translate(input : Enumerable(String), sl = "ZH", tl = "EN")
    raise "no more available keys" unless api_key = self.api_keys.last?
    call_api(api_key, input, sl: sl, tl: tl)
  rescue ex
    Log.warn { ex }
    raise ex unless self.api_keys.pop?
    self.translate(input, sl: sl, tl: tl)
  end

  FREE_API = "https://api-free.deepl.com"
  PRO_API  = "https://api.deepl.com"

  def self.call_api(api_key : String, input : Enumerable(String), sl = "ZH", tl = "EN")
    url = api_key.ends_with?(":fx") ? FREE_API : PRO_API

    body = URI::Params.build do |form|
      input.each { |term| form.add "text", term }
      form.add "source_lang", sl
      form.add "target_lang", tl
      form.add "split_sentences", "1"
    end

    headers = HTTP::Headers{
      "Authorization" => "DeepL-Auth-Key #{api_key}",
      "Content-Type"  => "application/x-www-form-urlencoded",
    }

    HTTP::Client.post("#{url}/v2/translate", headers: headers, body: body) do |res|
      res_body = res.body_io.gets_to_end
      raise res_body unless res.status.success?
      Array(Tran).from_json(res_body, root: "translations").map(&.text)
    end
  end

  struct Tran
    include JSON::Serializable
    getter text : String
  end

  # test = "能源、表情".split("、")
  # puts translate(test).to_pretty_json
end
