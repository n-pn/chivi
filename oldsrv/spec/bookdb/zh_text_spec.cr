require "spec"
require "../../src/bookdb/models/zh_text"
require "file_utils"

describe ZhText do
  it "correctly save content" do
    test = ZhText.new("test", "test", "test")

    FileUtils.mkdir_p(test.root)

    lines = ["1", "2", "3"]
    test.lines = lines

    test.save!
    test.load!

    test.lines.should eq(lines)
    FileUtils.rm_rf(test.root)
  end
end
