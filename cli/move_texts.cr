require "colorize"
require "file_utils"

dirs = Dir.glob("var/appcv/chtexts/*/")
puts "- input: #{dirs.size} folders"

OUT_DIR = "_db/prime/chtexts"

dirs.each_with_index do |dir, idx|
  files = Dir.glob("#{dir}/*.txt").reject { |f| File.size(f) < 1000 }
  next if files.empty?

  bname, sname = dir.split(".", 2)
  s_bid, _s_cid = File.basename(files.first).split(".", 2)

  out_dir = File.join(OUT_DIR, sname, s_bid)
  FileUtils.mkdir_p(out_dir)

  puts "- <#{idx + 1}/#{dirs.size}> #{out_dir}: #{files.size} entries"

  files.each do |inp_file|
    _s_bid, s_cid = File.basename(inp_file, ".txt").split(".", 2)
    out_file = File.join(out_dir, "#{s_cid}.txt")
    FileUtils.mv(inp_file, out_file)
  end
end
