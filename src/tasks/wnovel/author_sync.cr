ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../zroot/author"

select_stmt = "select rowid, name_zh, name_vi, name_mt from authors where rowid >= $1 and rowid <= $2"
wninfo_stmt = "update wninfos set author_vi = $1 where author_zh = $2"

upsert_stmt = <<-SQL
  insert into authors(zname, vname) values ($1, $2)
  on conflict (zname) do update set vname = excluded.vname
  returning id
  SQL

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  total = 0

  inputs = [] of {Int32, String, String}

  ZR::Author.open_db do |db|
    db.query_each(select_stmt, lower, upper) do |rs|
      total += 1
      rowid, name_zh, name_vi, name_mt = rs.read(Int32, String, String, String)
      name_vi = name_mt if name_vi.empty?
      inputs << {rowid, name_zh, name_vi}
    end
  end

  puts "- <authors> block: #{block}, books: #{total}"
  break if total == 0
  wa_ids = [] of {Int32, Int32}

  PGDB.exec "begin transaction"

  inputs.each do |rowid, name_zh, name_vi|
    puts "#{name_zh} => #{name_vi}"

    PGDB.exec wninfo_stmt, name_vi, name_zh
    wa_id = PGDB.query_one upsert_stmt, name_zh, name_vi, as: Int32
    wa_ids << {rowid, wa_id}
  end

  PGDB.exec "commit"

  ZR::Author.open_tx do |db|
    wa_ids.each do |rowid, wa_id|
      db.exec "update authors set wa_id = $1 where rowid = $2", wa_id, rowid
    end
  end
end
