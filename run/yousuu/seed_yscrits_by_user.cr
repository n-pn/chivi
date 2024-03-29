require "../../src/ysapp/data/yscrit_form"

DIR   = "var/ysraw/crits-by-user"
WHOLE = ARGV.includes?("--whole")
BRIEF = ARGV.includes?("--brief")

dirs = Dir.children(DIR)
dirs.each_with_index(1) do |yu_id, idx|
  files = Dir.glob("#{DIR}/#{yu_id}/*.zst")

  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! { |x| File.basename(x).split('.', 2).first.to_i? || 0 }
  total = files.size

  PG_DB.exec "begin"

  files.each_with_index(1) do |path, jdx|
    puts "- [#{idx}/#{dirs.size}] <#{jdx}/#{total}>: #{path}"
    seed_crit_by_user(path)
  rescue ex
    Log.error(exception: ex) { path }
  end

  PG_DB.exec "commit"
end

def seed_crit_by_user(path : String)
  json = read_zstd(path)
  return unless json.includes?("data")

  data = YS::RawBookComments.from_json(json)
  rtime = File.info(path).modification_time.to_unix

  crits = data.comments
  return if crits.empty?

  if BRIEF
    crits.each do |crit|
      next unless ztext = crit.ztext?

      PG_DB.exec <<-SQL, ztext, crit.yc_id.hexbytes
      update yscrits set ztext = $1 where yc_id = $2
      SQL
    end
  else
    YS::YscritForm.bulk_upsert!(crits, rtime: rtime)
    raw_user = crits.first.user

    PG_DB.exec <<-SQL, data.total, rtime, raw_user.id
      update ysusers
      set crit_total = $1, crit_rtime = $2
      where id = $3 and crit_total < $1
      SQL

    puts "yuser: #{raw_user.id}, crits: #{crits.size}".colorize.yellow
  end
end
