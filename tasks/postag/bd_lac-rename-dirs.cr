require "colorize"
require "file_utils"
require "../shared/bootstrap"

INP = "_db/vpinit/bd_lac/raw"
OUT = "_db/vpinit/lacout/sum"

dirs = Dir.children(INP)

dirs.each_with_index(1) do |inp_name, i|
  inp_dir = File.join(INP, inp_name)

  File.rename(File.join(inp_dir, "_all.sum"), File.join(out_dir, inp_name + ".tsv"))
  File.rename(File.join(inp_dir, "_all.log"), File.join(out_dir, inp_name + ".log"))
end
