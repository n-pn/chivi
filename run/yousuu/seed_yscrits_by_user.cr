require "../../src/ysapp/data/yscrit_form"

WHOLE = ARGV.includes?("--whole")

DIR = "var/ysraw/crits-by-user"
dirs = Dir.children(DIR)
dirs.each_with_index(1) do |yu_id, idx|
  files = Dir.glob("#{DIR}/#{yu_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }
  total = files.size

  files.each_with_index(1) do |path, jdx|
    puts "- [#{idx}/#{dirs.size}] <#{jdx}/#{total}>: #{path}"
    seed_crit_by_user(path)
  rescue ex
    Log.error(exception: ex) { path }
  end
end

def seed_crit_by_user(path : String)
  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  rtime = File.info(path).modification_time.to_unix

  crits = data.comments
  YS::YscritForm.bulk_upsert(crits, rtime: rtime)

  raw_user = crits.first.user
  PG_DB.exec <<-SQL, data.total, rtime, raw_user.id
    update ysusers
    set crit_total = $1, crit_rtime = $2
    where id = $3 and crit_total < $1
    SQL

  puts "yuser: #{raw_user.id}, crits: #{crits.size}".colorize.yellow
end
