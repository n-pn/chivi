require "json"
require "../../src/ysapp/data/_data"

record Ylist, vc_id : Int32, yc_id : String, yl_id : String, vl_id : Int32 do
  include JSON::Serializable
end

input = File.read_lines("var/ysapp/yscrit-yl_id-2.jsonl")
index = 0

input.each_slice(500) do |lines|
  index += 1
  puts index

  PG_DB.exec "begin"

  lines.each do |line|
    data = Ylist.from_json(line)

    PG_DB.exec <<-SQL, data.vl_id, data.yl_id.hexbytes, data.vc_id
    update yscrits set yslist_id = $1, yl_id = $2 where id = $3 and yslist_id = 0
    SQL
  end

  PG_DB.exec "commit"
end
