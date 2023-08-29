require "../../zroot/btitle"

current = ZR::Btitle.db.query_all("select name_zh from btitles", as: String).to_set

entries = DB.open("sqlite3:var/zroot/btitles.db3") do |db|
  db.query_all("select * from btitles", as: ZR::Btitle)
end

puts "- current: #{current.size}, previous: #{entries.size}"

entries.select!(&.name_zh.in?(current))

ZR::Btitle.db.open_tx do |db|
  entries.each(&.upsert!(db: db))
end

puts "- saved entries: #{entries.size}"
