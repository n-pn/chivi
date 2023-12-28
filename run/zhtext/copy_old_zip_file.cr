ENV["CV_ENV"] = "production"
require "../../src/_data/_data"

record Data, sname : String, sn_id : Int32, wn_id : Int32 do
  include DB::Serializable
end

mapping = {} of String => String

query = <<-SQL
  select sname, id as sn_id, wn_id from upstems
  where wn_id is not null order by id asc
  SQL

PGDB.query_all(query, as: Data).each do |data|
  mapping["#{data.sname}/#{data.wn_id}"] ||= "#{data.sname}/#{data.sn_id}"
end

# INP = "/www/var.chivi/zroot/rawtxt"
INP = "/www/cvbak/rzips"
OUT = "/2tb/zroot/restore"

mapping.each do |key, val|
  inp_file = "#{INP}/#{key}.zip"
  out_file = "#{OUT}/#{val}.zip"
  next unless File.file?(inp_file)
  # next if File.file?(out_file)

  Dir.mkdir_p(File.dirname(out_file))
  File.copy(inp_file, out_file)

  puts "#{out_file} recovered!"
end
