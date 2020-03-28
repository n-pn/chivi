require "json"

class Input
  include JSON::Serializable

  property status : String = "连载"
end

SITES = [
  "jx_la", "rengshu", "hetushu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
]
SITES.each do |site|
  files = Dir.glob("data/txt-tmp/serials/#{site}/*.json")
  status = Set(String).new
  files.each do |file|
    input = Input.from_json(File.read(file))
    status << input.status
  end

  File.write "data/txt-tmp/#{site}-status.txt", status.to_a.join("\n")
end
