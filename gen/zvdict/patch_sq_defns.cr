ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/mt_ai/data/pg_defn"
require "../../src/mt_ai/data/sq_defn"

start = Time.monotonic
zterms = ZR_DB.query_all "select * from zvterm", as: MT::PgDefn

puts Time.monotonic - start
mdatas = zterms.map { |x| MT::SqDefn.new(x) }
puts Time.monotonic - start

mdatas.group_by { |x| x.d_id % 10 }.each do |group, items|
  MT::SqDefn.db(group).open_tx do |db|
    items.each(&.upsert!(db: db))
  end

  puts "#{group}: #{Time.monotonic - start}"
end

puts mdatas.size

# nouns = mdatas.select do |defn|
#   epos = MT::MtEpos.from_value(defn.epos)
#   epos.nn? && defn.zstr.size < 2
# end

# puts "nouns: #{nouns.size}"

# verbs = mdatas.select do |defn|
#   epos = MT::MtEpos.from_value(defn.epos)

#   epos.vv? && defn.zstr.size < 3
# end

# puts "verbs: #{verbs.size}"

# adjts = mdatas.select do |defn|
#   epos = MT::MtEpos.from_value(defn.epos)
#   (epos.va? || epos.jj?) && defn.zstr.size < 3
# end

# puts "adjts: #{adjts.size}"
