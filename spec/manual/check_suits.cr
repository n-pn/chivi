require "../../src/cvmtl/mt_core"
MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_txt
end

DIR = "spec/engine/cases"

files = Dir.glob("#{DIR}/**/*.tsv")

files.each do |file|
  lines = File.read_lines(file)

  lines.each do |line|
    next if line.empty? || line.starts_with?('#')

    left, _right = line.split('\t')
    File.write("tmp/test.txt", left)
    puts [left, convert(left)]
  end
end
