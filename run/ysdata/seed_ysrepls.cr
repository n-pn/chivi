# seed ys repls data from crawled json in `var/ysraw/repls` folder

# notes:
# - sort files by modification time so older entries do not override newer entries
# - keep track of seeded entries so you don't have to seed twice

require "../../src/ysapp/_raw/raw_ys_repl"
require "../../src/ysapp/models/ys_repl"

DIR = "var/ysraw/repls"

Dir.children(DIR).each do |y_cid|
  seed_dir(y_cid)
end

UPDATE_STMT = "update yscrits set repl_total = $1 where y_cid = $2 and repl_total < $1"

def seed_dir(y_cid : String)
  files = Dir.glob("#{DIR}/#{y_cid}/*.json.zst")
  puts "#{y_cid}: #{files.size} files"

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
  PG_DB.exec UPDATE_STMT, repl_total, y_cid
  PG_DB.exec "commit"

  puts "- total: #{repl_total}, seeded: #{seeded.size}"
end

# save current page
def seed_page(json : String, seeded : Set(String), repl_total : Int32)
  data = YS::RawCritReplies.from_json(json)
  repl_total = data.total if repl_total < data.total

  repls = data.repls.reject!(&.y_rid.in?(seeded))
  YS::Ysrepl.bulk_upsert(repls)

  repls.each { |repl| seeded << repl.y_rid }
  {seeded, repl_total}
rescue error
  puts error
  puts json
  exit 1
end
