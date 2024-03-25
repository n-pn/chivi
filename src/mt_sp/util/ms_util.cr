require "json"
require "uuid"
require "http/client"

module SP::MsUtil
  class_getter sub_keys : Array({String, String}) do
    {{ read_file("#{__DIR__}/ms_auth.tsv") }}.lines.compact_map do |line|
      args = line.split('\t')
      next unless args.size > 1 && args[2]? == "work"
      {args[0], args[1]? || ""}
    end
  end

  def self.subkey_headers(sub_key : String, region : String = "")
    headers = HTTP::Headers{
      "Ocp-Apim-Subscription-Key" => sub_key,
      "Content-type"              => "application/json",
      "X-ClientTraceId"           => UUID.random.to_s,
    }

    headers["Ocp-Apim-Subscription-Region"] = region unless region.blank?
    headers
  end

  def self.bearer_headers(token : String)
    HTTP::Headers{
      "Authorization"   => "Bearer #{token}",
      "Content-type"    => "application/json",
      "X-ClientTraceId" => UUID.random.to_s,
    }
  end

  class_getter free_token : String do
    if token = @@free_token
      return token if @@free_until >= Time.utc
    end

    client = HTTP::Client.new(URI.parse("https://edge.microsoft.com"))
    client.connect_timeout = 2.seconds
    client.read_timeout = 5.seconds

    @@free_until = Time.utc + 8.minutes
    @@free_token = client.get("/translate/auth", &.body_io.gets_to_end)
  end

  class_property free_until = Time.utc
end

# test = "能源、表情".split("、")
# puts SP::Btran.translate(test).to_pretty_json
# puts SP::Btran.lookup(["in", "out"]).to_pretty_json
