require "pg"
require "sqlite3"
require "option_parser"

ENV["CV_ENV"] ||= "production"
Log.setup_from_env

require "../../rdapp/data/wnstem"

crawl = 0
regen = false

OptionParser.parse(ARGV) do |parser|
  parser.on("-c MODE", "crawl modes") { |x| crawl = x.to_i }
  parser.on("-r", "regenerate") { regen = true }
end

QUERY = "select id from wninfos order by id desc"
wn_ids = PGDB.query_all QUERY, as: Int32
puts "total: #{wn_ids.size}"

wstems = PGDB.query_all "select * from wnseeds where sname = '~avail'", as: RD::Wnstem
wstems = wstems.to_h { |x| {x.wn_id, x} }

FRESH = (Time.utc - 1.day).to_unix

wn_ids.each do |wn_id|
  wstem = wstems[wn_id]? || RD::Wnstem.new(wn_id, "~avail")
  next if wstem.rtime > FRESH && wstem.chap_total > 0
  prev_total = wstem.chap_total

  Log.info { "#{wn_id}: #{prev_total}, #{wstem.mtime}" }
  wstem.update!(crawl: crawl, regen: regen, umode: 0)

  case wstem.chap_total
  when .< prev_total then color = :red
  when .> prev_total then color = :green
  else                    color = :blue
  end

  Log.info { " => #{wstem.chap_total}, #{wstem.mtime}".colorize(color) }
rescue ex
  Log.error { ex.message }
end
