require "json"
require "fileutils"

DIR = "var/bookdb/serials"
INP = "var/bookdb/chfiles"
OUT = "var/appcv/chtexts"

inps = Dir.glob("#{INP}/*/")

inps.each do |inp_dir|
  ubid, seed = File.basename(inp_dir).split(".")

  info = JSON.parse File.read("#{DIR}/#{ubid}.json")
  sbid = info["seed_sbids"][seed]

  out_dir = File.join(OUT, "#{ubid}.#{seed}")
  FileUtils.mkdir_p(out_dir)

  files = Dir.children(inp_dir)
  puts "#{inp_dir}: #{files.size} files"

  files.each do |file|
    next unless File.extname(file) == ".txt"

    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, "#{sbid}.#{file}")
    # puts [inp_file, out_file]
    FileUtils.mv inp_file, out_file
  end
end
