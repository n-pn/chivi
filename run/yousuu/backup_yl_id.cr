require "json"
require "../../src/ysapp/data/_data"

file = File.open("var/ysapp/yscrit-yl_id-2.jsonl", "w")

stmt = <<-SQL
select id, encode(yc_id, 'hex') as yc_id, encode(yl_id, 'hex') as yl_id, yslist_id as vl_id
from yscrits where yslist_id <> 0
SQL

PG_DB.query_each stmt do |rs|
  line = {
    vc_id: rs.read(Int32),
    yc_id: rs.read(String),
    yl_id: rs.read(String),
    vl_id: rs.read(Int32),
  }

  file << line.to_json << '\n'
end

file.close
