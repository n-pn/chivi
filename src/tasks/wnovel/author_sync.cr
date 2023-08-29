ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../zroot/author"

author_sql = "select id, zname, vname from authors"
author_map = PGDB.query_all(author_sql, as: {Int32, String, String}).to_h do |id, zname, vname|
  {zname, {vname, id}}
end

puts "- in authors: #{author_map.size}"

wninfo_sql = "select id, author_zh, author_vi from wninfos"
wninfo_map = PGDB.query_all(wninfo_sql, as: {Int32, String, String}).group_by(&.[1])

puts "- in wninfos: #{wninfo_map.size}"

upsert_author_sql = <<-SQL
  insert into authors(zname, vname) values ($1, $2)
  on conflict (zname) do update set vname = excluded.vname
  returning id
  SQL

update_wninfo_sql = <<-SQL
  update wninfos
  set author_vi = $1
  where id = any($2)
  SQL

select_author_sql = <<-SQL
  select rowid, name_zh, name_vi, name_mt
  from authors
  where rowid >= $1 and rowid <= $2
  SQL

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  total = 0

  inputs = [] of {Int32, String, String}

  ZR::Author.db.open_ro do |db|
    db.query_each(select_author_sql, lower, upper) do |rs|
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

    if prev = author_map[name_zh]?
      prev_vi, wa_id = prev
      PGDB.exec(upsert_author_sql, name_zh, name_vi) if prev_vi != name_vi
      wa_ids << {rowid, wa_id}
    else
      wa_id = PGDB.query_one upsert_author_sql, name_zh, name_vi, as: Int32
      wa_ids << {rowid, wa_id}
    end

    if prevs = wninfo_map[name_zh]?
      prevs.select! { |_id, _zname, prev_vi| prev_vi != name_vi }
      unless prevs.empty?
        wn_ids = prevs.map(&.[0])
        PGDB.exec update_wninfo_sql, name_vi, wn_ids
      end
    end
  end

  PGDB.exec "commit"

  ZR::Author.db.open_tx do |db|
    wa_ids.each do |rowid, wa_id|
      db.exec "update authors set wa_id = $1 where rowid = $2", wa_id, rowid
    end
  end
end
