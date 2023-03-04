require "zstd"
require "http/client"

require "../_raw/raw_ys_book"

def read_zstd(path : String)
  file = File.open(path, "r")
  Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
end

URL     = "http://127.0.0.1:5400/_ys/books/info"
HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

path = "var/ysraw/books/000/12.latest.json.zst"
json = read_zstd(path)
# data = YS::RawYsBook.from_json(json)

HTTP::Client.post(URL, body: json, headers: HEADERS) do |res|
  puts res.body_io.gets_to_end
end
