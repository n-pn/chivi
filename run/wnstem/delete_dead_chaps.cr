ENV["CV_ENV"] = "production"

require "../../src/_data/_data"

WN_SQL = "select wn_id, chap_total from wnseeds where wn_id >= 0 and sname = $1 order by wn_id asc"
CH_SQL = "delete from chinfos where ch_no < 0 or ch_no > $1"

def delete_unreached(sname : String)
  inputs = PGDB.query_all WN_SQL, sname, as: {Int32, Int32}

  inputs.each do |wn_id, chmax|
    db_path = "var/stems/wn#{sname}/#{wn_id}.db3"
    DB.open("sqlite3:#{db_path}", &.exec(CH_SQL, chmax))
    puts db_path
  end
end

delete_unreached("~draft")
# delete_unreached("~chivi")
# delete_unreached("~avail")
