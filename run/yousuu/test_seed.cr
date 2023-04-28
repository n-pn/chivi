require "../../src/ysapp/data/yscrit_form"

def seed_crit_by_user(path : String)
  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  rtime = File.info(path).modification_time.to_unix

  crits = data.comments
  return if crits.empty?

  YS::YscritForm.bulk_upsert!(crits, rtime: rtime)

  raw_user = crits.first.user
  PG_DB.exec <<-SQL, data.total, rtime, raw_user.id
    update ysusers
    set crit_total = $1, crit_rtime = $2
    where id = $3 and crit_total < $1
    SQL

  puts "yuser: #{raw_user.id}, crits: #{crits.size}".colorize.yellow
end

seed_crit_by_user("var/ysraw/crits-by-user/1/1.latest.json.zst")
