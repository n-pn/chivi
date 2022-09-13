require "option_parser"
require "../src/mtlv1/mt_core"

inp_file = ""
out_file = ""

OptionParser.parse(ARGV) do |parser|
  parser.on("-i INP_FILE", "input file") { |i| inp_file = i }
  parser.on("-o OUT_FILE", "output file") { |i| out_file = i }
end

input = File.exists?(inp_file) ? File.read(inp_file) : STDIN.gets_to_end
output = CV::MtCore.trad_to_simp(input)

if out_file.blank?
  puts output
else
  File.write(out_file, output)
end
