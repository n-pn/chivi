require "../src/mt_v2/mt_core"
require "option_parser"

input = [] of String

ifile = ""
ofile = ""

uname = "~"
dname = "combine"

OptionParser.parse(ARGV) do |parser|
  parser.on("-i FILE", "Tệp dữ liệu") { |i| ifile = i }
  parser.on("-o FILE", "Tệp kết quả") { |o| ofile = o }
  parser.on("-u USER", "Tên người dùng") { |u| uname = u }
  parser.on("-d DICT", "Tên từ điển bộ") { |d| dname = "-" + d }
  parser.unknown_args { |x| input = x }
end

if ifile.empty?
  ofile = "cv-output.txt" if ofile.empty?
else
  input = File.read_lines(ifile)
  ofile = ifile.sub(File.extname(ifile), "-cv.txt") if ofile.empty?
end

CV::VpDict.root = "data"

engine = CV::MtCore.generic_mtl(dname, uname)

File.open(ofile, "w") do |io|
  input.each do |line|
    io.puts engine.translate(line)
  end
end
