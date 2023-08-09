ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../zroot/btitle"

select_stmt = "select rowid, name_zh, name_vi, name_mt, name_hv from btitles where rowid >= $1 and rowid <= $2"
wninfo_stmt = "update wninfos set btitle_vi = $1, btitle_hv = $2 where btitle_zh = $3"

upsert_stmt = <<-SQL
  insert into btitles(zname, vname, hname) values ($1, $2, $3)
  on conflict (zname) do update set vname = excluded.vname, hname = excluded.hname
  returning id
  SQL

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  total = 0

  inputs = [] of {Int32, String, String, String}

  ZR::Btitle.open_db do |db|
    db.query_each(select_stmt, lower, upper) do |rs|
      total += 1
      rowid, name_zh, name_vi, name_mt, name_hv = rs.read(Int32, String, String, String, String)

      name_vi = name_mt if name_vi.empty?
      name_vi = name_hv if name_vi.empty?

      inputs << {rowid, name_zh, name_vi, name_hv}
    end
  end

  puts "- <btitles> block: #{block}, books: #{total}"
  break if total == 0
  wb_ids = [] of {Int32, Int32}

  PGDB.exec "begin transaction"

  inputs.each do |rowid, name_zh, name_vi, name_hv|
    puts "#{name_zh} => #{name_vi}"

    PGDB.exec wninfo_stmt, name_vi, name_hv, name_zh

    wb_id = PGDB.query_one upsert_stmt, name_zh, name_vi, name_hv, as: Int32
    wb_ids << {rowid, wb_id}
  end

  PGDB.exec "commit"

  ZR::Btitle.open_tx do |db|
    wb_ids.each do |rowid, wb_id|
      db.exec "update btitles set wb_id = $1 where rowid = $2", wb_id, rowid
    end
  end
end
