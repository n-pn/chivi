require "spec"
require "file_utils"
require "../../src/filedb/chap_text"

describe ChapText do
  it "correctly save text" do
    test = ChapText.new("test", "test", "test")
    FileUtils.mkdir_p(test.root)

    lines = ["1", "2", "3"]
    text = lines.join("\n")
    test.data = text

    test.save!.load!
    test.data.should eq(text)
    test.zh_lines.should eq(lines)

    FileUtils.rm_rf(test.root)
  end
end
