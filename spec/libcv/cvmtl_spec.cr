require "./_helper"

files = Dir.glob("var/mtspecs/**/*.tsv")

files.each do |file|
  suite_name = File.basename(file, ".tsv")

  describe suite_name do
    lines = File.read_lines(file).reject(&.empty?)

    lines.each do |line|
      left, right = line.split('\t', 2)

      it left do
        convert(left).should eq(right)
      end
    end
  end
end
