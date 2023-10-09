require "pg"
require "sqlite3"
require "option_parser"

ENV["CV_ENV"] ||= "production"

require "../../rdapp/data/wnstem"

crawl = 0
regen = false

OptionParser.parse(ARGV) do |parser|
  parser.on("-c MODE", "crawl modes") { |x| crawl = x.to_i }
  parser.on("-r", "regenerate") { regen = true }
end

QUERY = "select id from wninfos order by id asc"
input = PGDB.query_all QUERY, as: Int32
puts "total: #{input.size}"

input.each do |wn_id|
  wstem = RD::Wnstem.load(wn_id, "~avail")
  next unless wstem.update!(crawl: crawl, regen: regen, umode: 0)
  Log.info { {wstem.wn_id, wstem.chap_total, wstem.mtime} }
rescue ex
  Log.error { ex.message }
end
