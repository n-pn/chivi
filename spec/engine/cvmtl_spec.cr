require "./_helper"

MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

files = Dir.glob("spec/engine/cases/*.tsv")

files.each do |file|
  suite_name = File.basename(file, ".tsv")
  next if suite_name.starts_with?("#")

  describe suite_name do
    lines = File.read_lines(file).reject(&.empty?)

    lines.each do |line|
      left, right = line.split('\t')
      next if left.starts_with?("#")

      it left do
        convert(left).should eq(right)
      end
    end
  end
end
