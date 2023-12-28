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
# INP = "/2tb/app.chivi/var/zroot/wntext"
# INP = "/mnt/serve/chivi.all/users"
INP = "/mnt/serve/chivi.all/ztext"
OUT = "/2tb/zroot/restore"

mapping.each do |key, val|
  files = Dir.glob("#{INP}/#{key}/*.gbk")
  next if files.empty?

  out_path = "#{OUT}/#{val}"
  Dir.mkdir_p(out_path)

  files.each do |inp_file|
    ch_no = File.basename(inp_file, ".gbk")
    out_file = "#{out_path}/#{ch_no}0.gbk"
    File.copy(inp_file, out_file)

    utime = File.info(inp_file).modification_time
    File.utime(utime, utime, out_file)
  end

  puts "#{out_path}: #{files.size} recovered!"
end
