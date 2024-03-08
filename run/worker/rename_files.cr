require "log"
require "json"
DIR = "/www/ztext/ctfile"

struct Meta
  include JSON::Serializable

  getter orig_fname : String
  getter brief_desc : String
  getter char_count : Int32
  getter text_cksum : UInt64
  getter title_count : Int32
  getter blank_count : Int32
  getter inner_count : Int32
end

files = Dir.glob("#{DIR}/*.json")
files.each do |json_path|
  json = Meta.from_json File.read(json_path)
  zstd_path = json_path.sub(".json", ".txt.zst")
  next unless File.file?(zstd_path)

  out_zstd_path = "/www/ztext/output/#{json.text_cksum.to_s(base: 32)}.txt.zst"

  puts "#{zstd_path} => #{out_zstd_path}"
  if File.file?(out_zstd_path)
    File.delete(zstd_path)
  else
    File.rename(zstd_path, out_zstd_path)
  end
end
