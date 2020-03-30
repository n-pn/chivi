require "./spec_helper"
require "../src/engine/dict"

describe CDict do
  # TODO:
  # - Test dict preload and reload

  describe ".load" do
    it "loads empty dict" do
      dict = CDict.load("spec/fixtures/nonexist.txt")
      dict.should_not be(nil)
      dict.size.should eq(0)
      dict.mtime.should eq(0)
    end

    it "loads existed dict" do
      dict = CDict.load("spec/fixtures/sample.txt")
      dict.should_not be(nil)
      dict.size.should eq(1)
      dict.mtime.should_not eq(0)
    end

    it "loads the same dict when reload == false" do
      dict1 = CDict.load("spec/fixtures/sample.txt")
      dict2 = CDict.load("spec/fixtures/sample.txt")
      dict1.should eq(dict2)
    end

    it "reloads dict file if reload == true" do
      dict1 = CDict.load("spec/fixtures/sample.txt")
      dict2 = CDict.load("spec/fixtures/sample.txt", reload: true)
      dict1.should_not eq(dict2)
    end
  end

  describe ".load!" do
    it "should raise when file not found!" do
      expect_raises(Exception) do
        dict = CDict.load!("spec/fixtures/nonexist.txt")
      end
    end
  end
end
