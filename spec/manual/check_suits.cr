require "../../src/cvmtl/mt_core"
MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

files = Dir.glob("var/tlspecs/*.tsv")

files.each do |file|
  suite_name = File.basename(file, ".tsv")
  next if suite_name.starts_with?("_")

  lines = File.read_lines(file).reject(&.empty?)

  lines.each do |line|
    left, _right = line.split('\t')
    File.write("tmp/test.txt", left)
    puts [left, convert(left)]
  end
end
