INP = "/2tb/var.chivi/ysraw/crits-by-list-score"
OUT = "var/.keep/yousuu/crits-bylist-score"

require "xxhash"
require "../src/_util/zstd_util"

def move_file(inp_file : String)
  json_data = ZstdUtil.read_file(inp_file) rescue File.read(inp_file)

  dirname = File.basename(File.dirname(inp_file))
  basename = File.basename(inp_file, ".json.zst")

  page, kind = basename.split('.')
  kind = XXHash.xxh32(json_data).to_s(base: 36) unless kind == "latest"

  out_file = "#{OUT}/#{dirname}/#{page}-#{kind}.json"

  Dir.mkdir_p(File.dirname(out_file))
  File.write(out_file, json_data)

  utime = File.info(inp_file).modification_time
  File.utime(utime, utime, out_file)

  File.delete(inp_file)
  puts "#{inp_file} moved to #{out_file}!"
end

files = Dir.glob("#{INP}/**/*.json.zst")
files.each do |file|
  move_file(file)
rescue ex
  puts [file, ex]
end

# files = Dir.glob("#{ERR}/**/*.json")
# files.each do |file|
#   yb_id = File.basename(File.dirname(file))

#
#   out_file = file.sub(ERR, OUT).sub(yb_id, real_id)

#   Dir.mkdir_p(File.dirname(out_file))
#   File.rename(file, out_file)
#   puts "#{file} => #{out_file}"
# rescue ex
#   puts [ex, file]
# end
