ENV["CV_ENV"] = "production"
require "../../src/wnapp/data/wnseed"
require "../../src/zroot/rmstem"

query = "select id, btitle_zh, author_zh from wninfos"
books = PGDB.query_all(query, as: {Int32, String, String}).to_h do |wn_id, btitle, author|
  {wn_id, {btitle, author}}
end

inputs = WN::Wnstem.get_all(&.<< "where sname like '!%' and sname <> '!chivi'")

outputs = inputs.map do |input|
  output = ZR::Rmstem.new(input.sname, input.s_bid)

  conf = Rmconf.load!(input.sname)
  output.rlink = conf.full_book_link(input.s_bid)
  output.rtime = input.rtime

  output.btitle, output.author = books[input.wn_id]
  output.wn_id = input.wn_id

  output.utime = input.mtime
  output.immut = input._flag > 0

  output.count = input.chap_total
  output.avail = input.chap_avail

  output
end

puts "to save: #{outputs.size}"
gets

ZR::Rmstem.db.open_tx do |db|
  outputs.each(&.upsert!(db: db))
end
