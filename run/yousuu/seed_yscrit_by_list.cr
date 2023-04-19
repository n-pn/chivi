require "colorize"
require "file_utils"
require "../../src/ysapp/data/yscrit"

DIR = "var/ysraw/crits-by-list"
Dir.children(DIR).each do |yl_id|
  files = Dir.glob("#{DIR}/#{yl_id}/*.zst")
  files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }

  files.each do |path|
    seed_crit_by_list(path, yl_id.hexbytes)
  rescue ex
    puts ex.inspect_with_backtrace.colorize.red
  end
end

def seed_crit_by_list(path : String, yl_id : Bytes)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawListEntries.from_json(json)
  return if data.books.empty?

  rtime = File.info(path).modification_time.to_unix
  YS::Yslist.update_book_total(yl_id, data.total, rtime)

  YS::Yscrit.bulk_upsert(data.books, save_text: true)
  YS::Yscrit.update_list_id(yl_id)

  puts "yslist: #{yl_id.join(&.to_s(16))}, total: #{data.books.size}".colorize.yellow
end
