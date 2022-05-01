require "colorize"
require "file_utils"
require "../../src/_init/postag_init.cr"

INP = "_db/vpinit/bd_lac/raw"
# OUT = "_db/vpinit/bd_lac/sum"

Dir.children(INP).each do |bslug|
  puts bslug
  `sed 's/ w/¦ w/g' *.tsv`
end
