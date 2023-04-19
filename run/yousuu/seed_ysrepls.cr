# seed ys repls data from crawled json in `var/ysraw/repls` folder

# notes:
# - sort files by modification time so older entries do not override newer entries
# - keep track of seeded entries so you don't have to seed twice

require "../../src/ysapp/_raw/raw_ysrepl"
require "../../src/ysapp/data/ysrepl"

DIR = "var/ysraw/repls"

Dir.children(DIR).each do |yc_id|
  seed_dir(yc_id)
end

UPDATE_STMT = "update yscrits set repl_total = $1 where yc_id = $2 and repl_total < $1"

def seed_dir(yc_id : String)
  files = Dir.glob("#{DIR}/#{yc_id}/*.json.zst")
  puts "#{yc_id}: #{files.size} files"

  files.sort_by! do |file|
    page = File.basename(file).split('.').first.to_i
    time = File.info(file).modification_time.to_unix
    {page, -time}
  end

  # tracking seeded replies
  seeded = Set(String).new

  repl_total = 0

  PG_DB.exec "begin transaction"

  files.each do |file|
    seeded, repl_total = seed_page(read_zstd(file), seeded, repl_total)
  end

  # update repl_total counter
  PG_DB.exec UPDATE_STMT, repl_total, yc_id
  PG_DB.exec "commit"

  puts "- total: #{repl_total}, seeded: #{seeded.size}"
end

# save current page
def seed_page(json : String, seeded : Set(String), repl_total : Int32)
  data = YS::RawCritReplies.from_json(json)
  repl_total = data.total if repl_total < data.total

  repls = data.repls.reject!(&.yr_id.in?(seeded))
  YS::Ysrepl.bulk_upsert!(repls)

  repls.each { |repl| seeded << repl.yr_id }
  {seeded, repl_total}
rescue ex
  puts ex.inspect_with_backtrace
  exit 1
end
