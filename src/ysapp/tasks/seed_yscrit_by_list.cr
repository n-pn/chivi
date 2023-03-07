require "colorize"
require "../models/ys_crit"

def seed_crit_by_list(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  y_lid = File.basename(File.dirname(path))
  rtime = File.info(path).modification_time.to_unix

  data = YS::RawListEntries.from_json(json)
  return if data.books.empty?

  yslist = YS::Yslist.load(y_lid)

  yslist.book_total = data.total if yslist.book_total < data.total
  yslist.book_rtime = rtime

  yslist.save!

  YS::Yscrit.bulk_upsert(data.books, yslist: yslist, save_text: false)
  puts "yslist: #{yslist.id}, total: #{data.books.size}".colorize.yellow
end

DIR = "var/ysraw/crits-by-list"
Dir.children(DIR).each do |y_uid|
  files = Dir.glob("#{DIR}/#{y_uid}/*.zst")
  files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }

  files.each do |path|
    seed_crit_by_list(path)
  rescue ex
    puts ex.colorize.red
  end
end
