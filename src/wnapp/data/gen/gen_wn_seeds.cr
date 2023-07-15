require "pg"
require "../../../cv_env"
require "../wn_seed"

input = [] of Array(DB::Any)

MAP_BG = {
  "biqugee":      "!biqugee.com",
  "bxwxorg":      "!bxwxorg.com",
  "rengshu":      "!rengshu.com",
  "shubaow":      "!shubaow.net",
  "duokan8":      "!duokan8.com",
  "paoshu8":      "!paoshu8.com",
  "miscs":        "!chivi.app",
  "xbiquge":      "!xbiquge.bz",
  "hetushu":      "!hetushu.com",
  "69shu":        "!69shu.com",
  "sdyfcm":       "!nofff.com",
  "nofff":        "!nofff.com",
  "5200":         "!5200.tv",
  "zxcs_me":      "!zxcs.me",
  "jx_la":        "!jx.la",
  "ptwxz":        "!ptwxz.com",
  "uukanshu":     "!uukanshu.com",
  "uuks":         "!uuks.org",
  "bxwxio":       "!bxwx.io",
  "133txt":       "!133txt.com",
  "biqugse":      "!biqugse.com",
  "bqxs520":      "!bqxs520.com",
  "yannuozw":     "!yannuozw.com",
  "kanshu8":      "!kanshu8.net",
  "biqu5200":     "!biqu5200.net",
  "b5200":        "!b5200.org",
  "uukanshu.com": "!uukanshu.com",
}

def map_sname(sname : String)
  return "_" if sname == "=base"
  return sname if sname[0] == '@'
  MAP_BG[sname]? || raise "unmapped sname: #{sname}"
end

DB.open(CV_ENV.database_url) do |db|
  query = <<-SQL
    select sname, s_bid::int, nvinfo_id::int, status + 1 as _flag, chap_count, utime, stime
    from wnseeds
    where sname <> '=user' and nvinfo_id >= 0
    order by nvinfo_id asc, id asc
  SQL

  db.query_each(query) do |rs|
    sname = map_sname(rs.read(String))

    entry = [
      sname,
      rs.read(Int32), # s_bid
      rs.read(Int32), # wn_id
      rs.read(Int32), # _flag
      rs.read(Int32), # chap_total
      rs.read(Int64), # mtime
      rs.read(Int64), # stime
    ] of DB::Any

    input << entry
  end
end

puts "output: #{input.size}"

query = <<-SQL
  replace into seeds (sname, s_bid, wn_id, _flag, chap_total, mtime, rm_stime)
  values (?, ?, ?, ?, ?, ?, ?)
SQL

db_path = WN::WnSeed.db_path
File.delete?(db_path)

DB.open("sqlite3://#{db_path}") do |db|
  WN::WnSeed.init_sql.split(";").each { |sql| db.exec(sql) unless sql.blank? }
  db.exec "pragma synchronous = normal"
  db.exec "begin"
  input.each do |args|
    db.exec(query, args: args)
  end
  db.exec "commit"
end
