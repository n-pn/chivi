require "option_parser"

TITLE_RE = /^第|[。！#\p{Pe}\p{Pf}]\s*$/

def fix_broken_lines(input : String, min_invalid = 15)
  output = String::Builder.new
  invalid = false

  input.each_line do |line|
    output << line unless line.blank?

    if (invalid || line.size > min_invalid) && line !~ TITLE_RE
      invalid = true
    else
      invalid = false
      output << '\n'
    end
  end

  output.to_s
end

inp_file = ""
out_file = ""
min_invalid = 15

OptionParser.parse(ARGV) do |parser|
  parser.on("-i INP_FILE", "input file") { |i| inp_file = i }
  parser.on("-o OUT_FILE", "output file") { |o| out_file = o }
  parser.on("-m MIN_INVALID", "minimal line char count to consider invalid") do |s|
    min_invalid = s.to_i
  end
end

input = inp_file.blank? ? STDIN.gets_to_end : File.read(inp_file)
output = fix_broken_lines(input, min_invalid: min_invalid)

if out_file.blank?
  puts output
else
  File.write(out_file, output)
end
