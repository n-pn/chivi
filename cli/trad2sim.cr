require "option_parser"
require "../src/mtlv1/mt_core"

def trad2sim(input : String, out_file : String? = nil)
  output = CV::MtCore.trad_to_simp(input)

  if out_file
    File.write(out_file, output)
  else
    STDOUT.puts output
  end
end

inp_file = nil
out_file = nil

OptionParser.parse(ARGV) do |parser|
  parser.on("-i INP_FILE", "input file") { |i| inp_file = i }
  parser.on("-o OUT_FILE", "output file") { |i| out_file = i }
end

input = inp_file.try { |x| File.read(x) } || STDIN.gets_to_end
trad2sim(input, out_file)
