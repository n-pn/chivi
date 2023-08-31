require "json"

module MT::MapEnt
  extend self

  class_getter texsmart_map : Hash(String, String) do
    Hash(String, String).from_json File.read("#{__DIR__}/texsmart_entmap.json")
  end

  def from_texsmart(ent : String)
    texsmart_map.fetch(ent, ent)
  end
end

# rawjson = File.read "#{__DIR__}/texsmart_rawmap.json"
# list = Array(NamedTuple(sid: String)).from_json(rawjson)

# output = {} of String => String

# list.each do |item|
#   output[item[:sid]] = "!" + item[:sid].split('.', 2).first.upcase
# end

# File.write("#{__DIR__}/texsmart_entmap.json", output.to_pretty_json)
