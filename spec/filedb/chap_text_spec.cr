require "spec"
require "file_utils"
require "../../src/filedb/chtext"

describe CV::Chtext do
  it "correctly save text" do
    test = CV::Chtext.load("test", "test", "test")
    FileUtils.mkdir_p(test.root)

    lines = ["1", "2", "3"]
    text = lines.join("\n")
    test.zh_lines = lines

    test.tap(&.save!).load!
    test.zh_lines.should eq(lines)

    FileUtils.rm_rf(test.root)
  end
end
