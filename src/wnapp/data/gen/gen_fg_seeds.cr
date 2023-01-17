require "pg"
require "sqlite3"

require "../../../cv_env"
require "../fg_seed"
require "../bg_seed"

include WN

S_BIDS = {} of {Int32, String} => Int32
BgSeed.repo.open_db do |db|
  db.query_each("select wn_id, sname, s_bid from seeds") do |rs|
    S_BIDS[rs.read(Int32, String)] = rs.read(Int32)
  end
end

input = [] of Array(DB::Any)

DB.open(CV_ENV.database_url) do |db|
  query = <<-SQL
    select s_bid, sname, last_sname, last_schid, chap_count, utime
    from chroots where sname = '=base' or sname like '@%' order by id asc
  SQL

  db.query_each(query) do |rs|
    s_bid, sname = rs.read(Int32, String)
    last_sname, last_schid = rs.read(String, String)
    chap_count, utime = rs.read(Int32, Int64)

    input << [
      s_bid, sname,
      last_sname, S_BIDS[{s_bid, last_sname}]? || 0,
      last_sname.empty? ? 0 : last_schid.to_i? || 0,
      chap_count, utime,
    ] of DB::Any
  end
end

query = <<-SQL
  replace into seeds (sname, s_bid, feed_sname, feed_s_bid, feed_s_cid, chap_total, mtime)
  values (?, ?, ?, ?, ?, ?, ?)
SQL

puts "output: #{input.size}"

db_path = FgSeed.db_path
File.delete?(db_path)

DB.open("sqlite3://#{db_path}") do |db|
  FgSeed.init_sql.split(";").each { |sql| db.exec sql rescue puts sql }

  db.exec "begin"
  input.each { |args| db.exec(query, args: args) }
  db.exec "end"
end
