require "pg"
require "sqlite3"

ENV["CV_ENV"] = "production"

require "../../src/rdlib/data/rmstem"

QUERY = "select * from rmstems where sname = $1 order by sn_id asc"

def update(sname : String, mode = 0)
  input = PGDB.query_all QUERY, sname, as: RD::Rmstem

  input.each do |rstem|
    rstem = rstem.update!(mode: 0)

    puts rstem.to_pretty_json
  end
end

ARGV.each do |sname|
  update(sname) if sname.starts_with?('!')
end
