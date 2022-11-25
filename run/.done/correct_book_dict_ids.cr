require "db"
require "sqlite3"
require "colorize"

out_db = DB.open("sqlite3://var/dicts/book.dic")
idx_db = DB.open("sqlite3://var/dicts/index.db")

at_exit { out_db.close; idx_db.close }

real_ids = {} of String => Int32
fake_ids = {} of String => Int32

idx_db.query_each "select name, id from dicts where id < 0" do |rs|
  real_ids[rs.read(String)[1..]] = -rs.read(Int32)
end

out_db.query_each "select name, id from dicts" do |rs|
  fake_ids[rs.read(String)] = rs.read(Int32)
end

out_db.exec "begin transaction"

fake_ids.each do |bhash, fake_id|
  if real_id = real_ids[bhash]?
    real_id += 1_000_000 # prevent duplicate

    out_db.exec "update terms set dic = ? where dic = ?", args: [real_id, fake_id]
    out_db.exec "update terms set dic = ? where dic = ?", args: [-real_id, -fake_id]
  else
    puts "#{fake_id} #{bhash} is missing!".colorize.red
    puts out_db.scalar "select count (*) from terms where dic = ?", args: [fake_id]
    out_db.exec "delete from terms where dic = ? or dic = ?", args: [fake_id, -fake_id]
  end
end

out_db.exec "update terms set dic = dic - 1000000 where dic > 1000000"
out_db.exec "update terms set dic = dic + 1000000 where dic < -1000000"
out_db.exec "drop table dicts"

out_db.exec "commit"
out_db.exec "vacuum"
