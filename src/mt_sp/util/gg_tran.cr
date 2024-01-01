require "json"
require "uuid"
require "http/client"

class SP::Gtran
  ENDPOINT = "https://translate.googleapis.com"
  API_PART = "/translate_a/single?client=gtx&text=&dt=t"

  struct TlEntry
    include JSON::Serializable
    getter text : String
    # getter to : String?
  end

  struct TlOutput
    include JSON::Serializable
    getter translations : Array(TlEntry)
  end

  HEADERS = HTTP::Headers{
    "Accept-Language" => "en-US,en;q=0.5",
  }

  def self.translate(text : String, source = "zh", target = "vi") : {String, String}
    href = "#{ENDPOINT}#{API_PART}&sl=#{source}&tl=#{target}&q="
    href += URI.encode_path(text)

    HTTP::Client.get(href, headers: HEADERS) do |res|
      raise "error #{res.status_code}" unless res.status.success?
      vstr, zstr = JSON.parse(res.body_io.gets_to_end).as_a.first.as_a.first.as_a
      # Log.warn { "mismatch: #{zstr} <=> #{text}" } if zstr != text
      {text, vstr.as_s}
    end
  end

  def self.translate(text : Array(String), source = "zh", target = "vi")
    zstr, vstr = translate(text.join('、'), source: source, target: target)
    text.zip(vstr.split(/,\s*/))
  end
end

# puts SP::Gtran.translate(["能源", "表情"])
