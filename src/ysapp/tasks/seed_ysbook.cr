require "colorize"
require "http/client"
require "../models/ys_book"

def sync_file(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawYsBook.from_json(json)
  data.info_rtime = File.info(path).modification_time.to_unix

  return unless model = YS::Ysbook.upsert!(data)

  puts "ysbook: #{model.id}, voters: #{model.voters}, nvinfo: #{model.nvinfo_id}".colorize.yellow
end

files = Dir.glob("var/ysraw/books/**/*.zst")
files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i }

files.each do |path|
  sync_file(path)
rescue ex
  puts ex.colorize.red
end
