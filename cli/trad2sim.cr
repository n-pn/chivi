require "option_parser"
require "../src/cvmtl/mt_core"

def convert(inp_text : String, out_file : String? = nil)
  output = CV::MtCore.trad_to_simp(inp_text)

  if out_file.empty?
    STDOUT.puts(output)
  else
    File.write(out_file, output)
  end
end

def run!(argv = ARGV)
  inp_file = ""
  out_file = ""

  OptionParser.parse(argv) do |parser|
    parser.on("-i INP_FILE", "input file") { |i| inp_file = i }
    parser.on("-o OUT_FILE", "output file") { |i| out_file = i }
  end

  # while line = gets
  #   puts CV::MtCore.trad_to_simp(line)
  # end

  input = inp_file.empty? ? STDIN.gets_to_end : File.read(inp_file)
  convert(input, out_file)
end

run!(ARGV)
