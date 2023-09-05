require "../../src/mt_ai/data/mt_defn"
require "../../src/_util/char_util"
require "../../src/_util/viet_util"

existed = MT::MtDefn.db("regular").open_ro do |db|
  query = "select zstr, cpos from defns"
  db.query_all(query, as: {String, String}).to_set
end

entries = [] of MT::MtDefn

MT::MtDefn.db("book/-1").open_ro do |db|
  db.query_each("select * from defns") do |rs|
    entry = rs.read(MT::MtDefn)
    entries << entry unless existed.includes?({entry.zstr, entry.cpos})
  end
end

puts entries.size

MT::MtDefn.db("regular").open_tx do |db|
  entries.each(&.upsert!(db: db))
end
