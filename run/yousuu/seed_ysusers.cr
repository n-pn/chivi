require "../../src/ysapp/_raw/raw_ysuser"
require "../../src/ysapp/data/ysuser"

def seed_user(path : String)
  puts path

  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawYsuser.from_json(json)

  yu_id = File.basename(path).split('.').first
  rtime = File.info(path).modification_time.to_unix
  ysuser = YS::Ysuser.load(data.user.id)

  ysuser.set_data(data.user)
  ysuser.set_stat(data, rtime)

  ysuser.save!

  puts "ysuser: #{ysuser.id}, uname: #{ysuser.vname}".colorize.yellow
end

DIR = "var/ysraw/users"

files = Dir.glob("#{DIR}/*.zst")

files.select!(&.ends_with?("latest.json.zst")) unless ARGV.includes?("--all")
files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }

files.each do |path|
  seed_user(path)
rescue ex
  puts ex.inspect_with_backtrace.colorize.red
end
