require "pg"

require "../src/cv_env"

require "../src/wnapp/data/wn_seed"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

upsert_sql = <<-SQL
  insert into wnseeds (
    wn_id, sname, s_bid,
    chap_total, chap_avail,
    mtime, atime,
    rm_links, rm_stime,
    edit_privi, read_privi,
    _flag
  ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
  on conflict (wn_id, sname) do update set
    s_bid = excluded.s_bid,
    chap_total = excluded.chap_total,
    chap_avail = excluded.chap_avail,
    mtime = excluded.mtime,
    atime = excluded.atime,
    rm_links = excluded.rm_links,
    rm_stime = excluded.rm_stime,
    edit_privi = excluded.edit_privi,
    read_privi = excluded.read_privi,
    _flag = excluded._flag
SQL

PG_DB.exec "begin transaction"

WN::WnSeed.repo.db.query_each "select * from seeds order by wn_id asc" do |rs|
  seed = rs.read(WN::WnSeed)

  PG_DB.exec upsert_sql, seed.wn_id, seed.sname, seed.s_bid,
    seed.chap_total, seed.chap_avail,
    seed.mtime, seed.atime,
    Array(String).from_json(seed.rm_links), seed.rm_stime,
    seed.edit_privi, seed.read_privi, seed._flag

  puts "#{seed.wn_id}/#{seed.sname} (#{seed.chap_total}) synced"
end

PG_DB.exec "commit"
