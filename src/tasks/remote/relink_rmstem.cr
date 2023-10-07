require "pg"
require "sqlite3"
require "option_parser"

ENV["CV_ENV"] ||= "production"

require "../../rdapp/data/rmstem"

QUERY = "select * from rmstems where sname = $1 order by rtime asc"

def update(sname : String, crawl = 0, regen = true)
  input = PGDB.query_all QUERY, sname, as: RD::Rmstem

  input.each do |rstem|
    next unless rstem = rstem.update!(crawl: crawl, regen: regen)
    Log.info { [sname, rstem.sn_id, rstem.chap_count, rstem.status_int, rstem.update_int] }
  rescue ex
    Log.error { ex.message }
  end
end

crawl = 0
regen = false
input = ["!69shuba.com"]

OptionParser.parse(ARGV) do |parser|
  parser.on("-c MODE", "crawl modes") { |x| crawl = x.to_i }
  parser.on("-r", "regenerate") { regen = true }
  parser.unknown_args { |args| input = args.select!(&.starts_with?('!')) }
end

input.each { |sname| update(sname, crawl: crawl, regen: regen) }
