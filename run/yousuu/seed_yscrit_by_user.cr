require "colorize"
require "http/client"
require "../../src/ysapp/data/yscrit"

DIR = "var/ysraw/crits-by-user"
Dir.children(DIR).each do |yu_id|
  files = Dir.glob("#{DIR}/#{yu_id}/*.zst")
  files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }

  files.each do |path|
    seed_crit_by_user(path)
  rescue ex
    puts ex.colorize.red
  end
end

def seed_crit_by_user(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  return if data.comments.empty?

  raw_ysuser = data.comments.first.user
  rtime = File.info(path).modification_time.to_unix

  YS::Ysuser.update_crit_total(raw_ysuser.id, data.total, rtime)
  YS::Yscrit.bulk_upsert(data.comments)

  puts "ysuser: #{raw_ysuser.id}, total: #{data.comments.size}".colorize.yellow
end
