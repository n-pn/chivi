require "pg"
require "../../../cv_env"

require "../bg_seed"

input = [] of Array(DB::Any)

DB.open(CV_ENV.database_url) do |db|
  query = <<-SQL
    select sname, s_bid, nvinfo_id, status, chap_count, last_schid, utime, stime
    from chroots where sname not in ('=base', '=user') order by id asc
  SQL

  db.query_each(query) do |rs|
    input << [
      rs.read(String),                   # sname
      rs.read(Int32),                    # s_bid
      rs.read(Int64).to_i,               # wn_id
      rs.read(Int32),                    # _flag
      rs.read(Int32),                    # chap_total
      rs.read(String).try(&.to_i?) || 0, # last_s_cid
      rs.read(Int64),                    # mtime
      rs.read(Int64),                    # stime
    ] of DB::Any
  end
end

puts "output: #{input.size}"

query = <<-SQL
  replace into seeds (sname, s_bid, wn_id, _flag, chap_total, last_s_cid, mtime, stime)
  values (?, ?, ?, ?, ?, ?, ?, ?)
SQL

db_path = WN::BgSeed.db_path
File.delete?(db_path)

DB.open("sqlite3://#{db_path}") do |db|
  WN::BgSeed.init_sql.split(";").each { |sql| db.exec sql rescue puts sql }

  db.exec "begin"
  input.each { |args| db.exec(query, args: args) }
  db.exec "end"
end
