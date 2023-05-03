require "pg"
require "sqlite3"
require "../../src/cv_env"

book_ids = Set(Int32).new

# add all book ids that has text submitted by users

DB.open("sqlite3:var/chaps/seed-infos.db") do |db|
  sql = "select distinct(wn_id) from seeds where wn_id > 0 and (sname like '@%'"

  sql += " or sname = '!chivi.app' or sname = '!hetushu.com'"
  sql += " or sname = '!zxcs.me' or sname = '!rengshu.com'"
  sql += ")"

  book_ids.concat db.query_all(sql, as: Int32)
end

# add book id from main database:

db = DB.open(CV_ENV.database_url)
at_exit { db.close }

user_book_sql = "select distinct(nvinfo_id::int) from ubmemos where status > 0 and nvinfo_id > 0"
book_ids.concat db.query_all(user_book_sql, as: Int32)

output = [] of {Int32, String, String}

book_ids.each_slice(100) do |slice|
  sql = String.build do |io|
    io << "select id::int, bslug, vname from wninfos where id in ("
    (1..slice.size).join(io, ", ") { |x, i| i << '$' << x }
    io << ')'
  end

  db.query_each(sql, args: slice) do |rs|
    output << rs.read(Int32, String, String)
  end
end

rank_book_sql = "select id::int, bslug, vname from wninfos order by voters desc, rating desc limit 20000"
db.query_each(rank_book_sql) do |rs|
  id, bslug, vname = rs.read(Int32, String, String)
  next if book_ids.includes?(id)

  book_ids << id
  output << {id, bslug, vname}
end

book_ids.concat db.query_all(rank_book_sql, as: Int32)

puts book_ids.size

output.sort_by!(&.first)

File.open("var/cvmtl/corpus-books.tsv", "w") do |file|
  output.each do |id, bslug, vname|
    file << id << '\t' << bslug << '\t' << vname << '\n'
  end
end
