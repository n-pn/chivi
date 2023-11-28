require "../../src/mt_ai/data/m_cache"

INP  = "/2tb/var.chivi/cache/mdata.old"
TYPE = ARGV[0]? || "ele_s"

cache = Hash(Int32, Array(MT::MCache)).new { |h, k| h[k] = [] of MT::MCache }

Dir.glob("#{INP}/*.#{TYPE}.db3").each do |db_path|
  items = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    db.query_all("select * from mcache", as: MT::MCache)
  end

  puts "#{db_path}: #{items.size}"

  items.each do |item|
    cache[item.tok.count(&.!= '\t')] << item
  end
end

cache.each do |block, items|
  puts "(#{TYPE}) #{block}: #{items.size} size"
  MT::MCache.load_db(block, TYPE).open_tx do |db|
    items.each(&.upsert!(db: db))
  end
end
