require "json"
require "../../src/ysapp/data/_data"

# record Ztext, id : Int32, ztext : String do
#   include JSON::Serializable
# end

# input = File.read_lines("var/ysapp/yscrit-ztext-2.jsonl")
# input.each_slice(500) do |lines|
#   PG_DB.exec "begin"

#   lines.each do |line|
#     data = Ztext.from_json(line)
#     next if data.ztext == "$$$"

#     PG_DB.exec <<-SQL, data.ztext, data.id
#     update yscrits set ztext = $1 where id = $2 and ztext = ''
#   SQL
#   end

#   PG_DB.exec "commit"
# end

record Ztext, yc_id : String, ztext : String do
  include JSON::Serializable
end

input = File.read_lines("var/ysapp/yscrits-ztext-orig.jsonl")
input.each_slice(500) do |lines|
  PG_DB.exec "begin"

  lines.each do |line|
    data = Ztext.from_json(line)
    next if data.ztext == "$$$"
    PG_DB.exec <<-SQL, data.ztext, data.yc_id.hexbytes
    update yscrits set ztext = $1 where yc_id = $2 and ztext = ''
  SQL
  end

  PG_DB.exec "commit"
end
