require "colorize"
require "file_utils"
require "../../src/_init/postag_init.cr"

# INP = "_db/vpinit/bd_lac/raw"
OUT = "_db/vpinit/bd_lac/sum"

Dir.glob("#{OUT}/*.tsv").each do |file|
  puts file
  CV::PostagInit.new(file).save!(sort: true)
end
