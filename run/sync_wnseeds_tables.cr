require "../src/wnapp/data/wn_seed"
require "../src/_data/wnovel/wnseed"

STMT = "select * from seeds order by wn_id asc, sname asc"
inputs = DB.open("sqlite3:var/chaps/seed-infos.db", &.query_all(STMT, as: WN::WnSeed))

PGDB.exec "begin transaction"

inputs.each do |input|
  next if input.wn_id < 0
  output = CV::Wnseed.new(wn_id: input.wn_id, sname: input.sname, s_bid: input.s_bid)

  output.chap_total = input.chap_total
  output.chap_avail = input.chap_avail

  output.created_at = Time.unix(input.mtime)
  output.updated_at = Time.unix(input.mtime)

  output.rlink = Array(String).from_json(input.rm_links).first? || ""
  output.rtime = input.rm_stime

  output.privi = input.edit_privi.to_i16
  output._flag = input._flag.to_i16

  output.upsert!

  puts "#{input.wn_id}/#{input.sname} (#{input.chap_total}) synced"
rescue ex
  puts [input.wn_id, input.sname, ex.message.colorize.red]
end

PGDB.exec "commit"
