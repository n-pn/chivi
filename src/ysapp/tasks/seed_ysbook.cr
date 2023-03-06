require "zstd"
require "colorize"
require "http/client"
require "../_raw/raw_ys_book"

def read_zstd(path : String)
  file = File.open(path, "r")
  Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
end

URL     = "http://127.0.0.1:5400/_ys/books/info"
HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

files = Dir.glob("var/ysraw/books/**/*.zst")
files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i }

files.each do |path|
  puts path
  json = read_zstd(path)
  next unless json.includes?("data")

  HTTP::Client.post(URL, body: json, headers: HEADERS) do |res|
    puts res.body_io.gets_to_end.colorize.yellow
  end
end
