require "zstd"
require "../../src/_util/hash_util"

INP = "var/ysraw/lists"
OUT = "var/ysraw/lists"

ZSTD = Zstd::Compress::Context.new(level: 3)

files = Dir.glob("#{INP}/*.json")
puts " #{files.size}"

files.each do |inp_path|
  puts inp_path

  data = File.read(inp_path)
  hash = HashUtil.encode32(HashUtil.fnv_1a(data))

  id = File.basename(inp_path, ".json")

  out_path = File.join(OUT, "#{id}.#{hash}.json.zst")
  File.write(out_path, ZSTD.compress(data.to_slice))

  mtime = File.info(inp_path).modification_time
  File.utime(mtime, mtime, out_path)

  File.rename(inp_path, inp_path + ".done")
end
