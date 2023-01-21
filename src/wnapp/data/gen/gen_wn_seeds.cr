require "pg"
require "../../../cv_env"
require "../wn_seed"

input = [] of Array(DB::Any)

def map_sname(sname : String)
  case sname
  when "=user"            then {nil, nil}
  when "=base"            then {"-", nil}
  when .starts_with?('@') then {sname, sname.sub("@", "+")}
  else                         {nil, "!" + sname}
  end
end

DB.open(CV_ENV.database_url) do |db|
  query = <<-SQL
    select sname, s_bid::int, nvinfo_id::int, status + 1 as _flag, chap_count, utime, stime
    from chroots order by id asc
  SQL

  db.query_each(query) do |rs|
    entry = [
      rs.read(String), # sname
      rs.read(Int32),  # s_bid
      rs.read(Int32),  # wn_id
      rs.read(Int32),  # _flag
      rs.read(Int32),  # chap_total
      rs.read(Int64),  # mtime
      rs.read(Int64),  # stime
    ] of DB::Any

    fg_sname, bg_sname = map_sname(entry[0].as(String))
    input << entry.dup.tap { |x| x[0] = fg_sname } if fg_sname
    input << entry.dup.tap { |x| x[0] = bg_sname } if bg_sname
  end
end

puts "output: #{input.size}"

query = <<-SQL
  replace into seeds (sname, s_bid, wn_id, _flag, chap_total, mtime, rtime)
  values (?, ?, ?, ?, ?, ?, ?)
SQL

db_path = WN::WnSeed.db_path
File.delete?(db_path)

DB.open("sqlite3://#{db_path}") do |db|
  WN::WnSeed.init_sql.split(";").each { |sql| db.exec(sql) unless sql.blank? }
  db.exec "pragma synchronous = normal"
  db.exec "begin"
  input.each { |args| db.exec(query, args: args) }
  db.exec "end"
end
