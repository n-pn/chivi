require "../../src/mt_v2/engine"
MTL = MT::Engine.new("combine")

def convert(input : String)
  MTL.cv_plain(input).to_txt(apply_cap: false)
end

DIR = "var/mt_v2/tests"

files = Dir.glob("#{DIR}/**/*.tsv")

files.each do |file|
  lines = File.read_lines(file)

  lines.each do |line|
    next if line.empty? || line.starts_with?('#')

    left, right = line.split('\t')
    File.write("tmp/test.txt", left)
    puts [left, convert(left), right]
  end
end
