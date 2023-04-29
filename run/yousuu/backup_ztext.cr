require "json"
require "../../src/ysapp/data/_data"

file = File.open("var/ysapp/yscrit-ztext.jsonl", "w")

PG_DB.query_each "select id, encode(yc_id, 'hex') as yc_id, ztext from yscrits where ztext <> ''" do |rs|
  vc_id, yc_id, ztext = rs.read(Int32, String, String)
  next if yc_id.size != 24

  line = {vc_id: vc_id, yc_ic: yc_id, ztext: ztext}
  file << line.to_json << '\n'
end

file.close
