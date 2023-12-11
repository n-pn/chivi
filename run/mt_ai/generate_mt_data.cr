require "../../src/mt_ai/data/mt_data"

start = Time.monotonic
zterms = ZR_DB.query_all "select * from zvterm", as: MT::ZvTerm

puts Time.monotonic - start
mdatas = zterms.map { |x| MT::MtData.new(x) }

puts Time.monotonic - start

Dir.glob(MT::MtData::DIR + "/*.db3") do |file|
  File.delete(file)
end

mdatas.group_by { |x| x.d_id % 10 }.each do |group, items|
  MT::MtData.db(group).open_tx do |db|
    items.each(&.upsert!(db: db))
  end
  puts Time.monotonic - start
end

puts mdatas.size
