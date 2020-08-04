require "fileutils"

INP = "var/appcv/.relics/texts"
OUT = "var/appcv/chtexts"

inps = Dir.glob("#{INP}/*/")

inps.each do |inp_dir|
  name, seed, sbid = File.basename(inp_dir).split(".")
  name = name.ljust(8, "0")

  out_dir = File.join(OUT, "#{name}.#{seed}")
  FileUtils.mkdir_p(out_dir)

  files = Dir.children(inp_dir)
  puts "#{inp_dir}: #{files.size} files"

  files.each do |file|
    next unless File.extname(file) == ".txt"

    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, "#{sbid}.#{file}")

    FileUtils.mv inp_file, out_file
  end
end
