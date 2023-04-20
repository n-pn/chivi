require "../src/wnapp/data/wn_seed"
require "../src/_data/wnovel/wnseed"

STMT = "select * from seeds order by wn_id asc, sname asc"

WN::WnSeed.repo.db.query_each STMT do |rs|
  input = rs.read(WN::WnSeed)

  output = CV::Wnseed.new(
    wn_id: input.wn_id,
    sname: input.sname,
    s_bid: input.s_bid,
  )

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
  puts ex
end
