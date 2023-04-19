require "colorize"
require "../../src/ysapp/data/yscrit"

DIR = "var/ysraw/crits-by-book"
Dir.children(DIR).each do |yb_id|
  files = Dir.glob("#{DIR}/#{yb_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }

  files.each do |path|
    seed_crit_by_book(path)
  rescue ex
    puts ex.inspect_with_backtrace.colorize.red
  end
end

def seed_crit_by_book(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  yl_id = File.basename(File.dirname(path))
  rtime = File.info(path).modification_time.to_unix

  data = YS::RawBookComments.from_json(json)
  return if data.comments.empty?

  ysbook = data.comments.first.book

  YS::Ysbook.update_crit_total(ysbook.id, data.total)
  YS::Yscrit.bulk_upsert(data.comments)

  puts "ysbook: #{ysbook.id}, total: #{data.comments.size}".colorize.yellow
end
