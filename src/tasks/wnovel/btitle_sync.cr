ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../zroot/btitle"

btitle_sql = "select id, zname, vname, hname from btitles"
btitle_map = PGDB.query_all(btitle_sql, as: {Int32, String, String, String}).to_h do |id, zname, vname, hname|
  {zname, {vname, hname, id}}
end

puts "- in btitles: #{btitle_map.size}"

wninfo_sql = "select id, btitle_zh, btitle_vi, btitle_hv from wninfos"
wninfo_map = PGDB.query_all(wninfo_sql, as: {Int32, String, String, String}).group_by(&.[1])

puts "- in wninfos: #{wninfo_map.size}"

select_btitle_sql = <<-SQL
  select rowid, name_zh, name_vi, name_mt, name_hv
  from btitles
  where rowid >= $1 and rowid <= $2
  SQL

upsert_btitle_sql = <<-SQL
  insert into btitles(zname, vname, hname) values ($1, $2, $3)
  on conflict (zname) do update set
    vname = excluded.vname,
    hname = excluded.hname
  returning id
  SQL

update_wninfo_sql = <<-SQL
  update wninfos
  set btitle_vi = $1, btitle_hv = $2
  where id = any($3)
  SQL

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  total = 0

  inputs = [] of {Int32, String, String, String}

  ZR::Btitle.db.open_ro do |db|
    db.query_each(select_btitle_sql, lower, upper) do |rs|
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
    # puts "#{name_zh} => #{name_vi}"

    if prev = btitle_map[name_zh]?
      prev_vi, prev_hv, wb_id = prev
      if prev_vi != name_vi || prev_hv != name_hv
        PGDB.exec(upsert_btitle_sql, name_zh, name_vi, name_hv)
      end

      wb_ids << {rowid, wb_id}
    else
      wb_id = PGDB.query_one(upsert_btitle_sql, name_zh, name_vi, name_hv, as: Int32)
      wb_ids << {rowid, wb_id}
    end

    if prevs = wninfo_map[name_zh]?
      prevs.select! { |_id, _zname, prev_vi, prev_hv| prev_vi != name_vi || prev_hv != name_hv }

      unless prevs.empty?
        wn_ids = prevs.map(&.[0])
        PGDB.exec update_wninfo_sql, name_vi, name_hv, wn_ids
      end
    end
  end

  PGDB.exec "commit"

  ZR::Btitle.db.open_tx do |db|
    wb_ids.each do |rowid, wb_id|
      db.exec "update btitles set wb_id = $1 where rowid = $2", wb_id, rowid
    end
  end
end
