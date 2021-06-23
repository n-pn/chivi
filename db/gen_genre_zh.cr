require "json"
require "../src/tabkv/value_map"
require "../src/cutil/text_utils"

zh_map = CV::ValueMap.new("./db/nv_fixes/bgenres_zh.tsv")
vi_map = CV::ValueMap.new("./db/nv_fixes/bgenres_vi.tsv")

zh_out = Hash(String, Array(String)).new do |h, k|
  h[k] = [] of String
end

vi_out = Hash(String, String).new

zh_map.data.each do |key, vals|
  vals.each do |val|
    next unless vi = vi_map.fval(val)
    vi_out[CV::TextUtils.slugify(vi)] = vi
    zh_out[key] << vi
  end
end

File.write("db/mapping/zh_genres.json", zh_out.to_pretty_json)
File.write("db/mapping/vi_genres.json", vi_out.to_pretty_json)
File.write("db/mapping/vi_genres.txt", vi_out.values.join("\n"))
