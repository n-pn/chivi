require "json"
require "http/client"

module SP::BdTran
  BD_API = "https://fetch.nipin.workers.dev?q=https://fanyi.baidu.com/ait/text/translate"

  HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

  def self.translate(ztext : String, sl = "zh", tl = "vie")
    body = build_body(ztext, sl, tl).to_json

    HTTP::Client.post(BD_API, headers: HEADERS, body: body) do |res|
      raise res.body unless res.success?
      extract_tran(res.body_io.gets_to_end).data.map(&.dst)
    end
  end

  def self.build_body(ztext : String, sl = "zh", tl = "vie")
    {
      query:      ztext,
      from:       sl,
      to:         tl,
      reference:  "",
      corpusIds:  [] of Int32,
      qcSettings: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"],
      domain:     "common",
    }
  end

  struct Data
    include JSON::Serializable

    @[JSON::Field(root: "list")]
    getter data : Array(Item)

    struct Item
      include JSON::Serializable
      getter dst : String
    end
  end

  def self.extract_tran(input : String)
    input.each_line do |line|
      next unless line.includes?("event\":\"Translating\"")
      return Data.from_json(line.lchop("data: "))
    end

    raise "invalid #{input}!"
  end

  # puts translate("第２章\n“宿主基因过于普通！”")
end
