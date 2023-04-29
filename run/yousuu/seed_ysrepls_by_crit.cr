# seed ys repls data from crawled json in `var/ysraw/repls` folder

# notes:
# - sort files by modification time so older entries do not override newer entries
# - keep track of seeded entries so you don't have to seed twice

require "../../src/ysapp/data/ysrepl_form"
require "../../src/ysapp/data/ysuser_form"

DIR   = "var/ysraw/repls-by-crit"
WHOLE = ARGV.includes?("--whole")

Dir.children(DIR).each do |yc_id|
  files = Dir.glob("#{DIR}/#{yc_id}/*.json.zst")
  files.select!(&.ends_with?("latest.json.zst")) unless WHOLE
  next if files.empty?

  files.sort_by! do |file|
    page = File.basename(file).split('.').first.to_i
    time = File.info(file).modification_time.to_unix
    {page, -time}
  end

  seeded = Set(String).new

  max_count = 0
  vc_id = YS::DBRepo.get_vc_id(yc_id.hexbytes)

  files.each do |file|
    seeded, max_count = seed_page(file, vc_id, seeded, max_count)
  rescue ex
    Log.error(exception: ex) { file }
  end

  # update max_count counter
  PG_DB.exec <<-SQL, max_count, yc_id.hexbytes
    update yscrits set repl_total = $1
    where yc_id = $2 and repl_total < $1
    SQL

  puts "- <#{yc_id}> total: #{max_count}, seeded: #{seeded.size}"
end

# save current page
def seed_page(path : String, vc_id : Int32, seeded : Set(String), max_count : Int32)
  json = read_zstd(path)

  data = YS::RawCritReplies.from_json(json)
  max_count = data.total if max_count < data.total

  repls = data.repls.reject!(&.yr_id.in?(seeded))
  rtime = File.info(path).modification_time.to_unix

  YS::YsuserForm.bulk_upsert!(repls.map(&.user))
  YS::YsreplForm.bulk_upsert!(repls, rtime, vc_id)

  repls.each { |repl| seeded << repl.yr_id }
  {seeded, max_count}
end
