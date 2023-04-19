require "colorize"
require "http/client"
require "../../src/ysapp/data/yscrit"

def seed_crit_by_user(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  return if data.comments.empty?

  ysuser = YS::Ysuser.upsert!(data.comments.first.user)

  ysuser.crit_total = data.total if ysuser.crit_total < data.total
  ysuser.crit_rtime = File.info(path).modification_time.to_unix

  ysuser.save!

  YS::Yscrit.bulk_upsert(data.comments, save_text: false)
  puts "ysuser: #{ysuser.id}, total: #{data.comments.size}".colorize.yellow
end

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
