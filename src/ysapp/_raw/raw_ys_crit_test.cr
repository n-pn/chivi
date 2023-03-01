require "zstd"
require "./raw_ys_crit"

path = "var/ysraw/crits-by-user/1462959/1.latest.json.zst"

file = File.open(path, "r")
json = Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)

data = YS::RawYsCrit.from_book_json(json)
puts data
