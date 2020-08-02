require "../spec_helper"
require "../../src/libcv/library/base_dict"

describe Libcv::BaseDict do
  # TODO:
  # - Test dict preload and reload

  describe ".load" do
    it "loads empty dict" do
      dict = Libcv::BaseDict.load!("spec/_tests/nonexist.txt")
      dict.should_not be(nil)

      dict.size.should eq(0)
    end

    it "loads existed dict" do
      dict = Libcv::BaseDict.load!("spec/_tests/sample-lexfile.dic")
      dict.should_not be(nil)

      dict.size.should eq(1)
    end
  end

  describe ".load!" do
    it "should raise when file not found!" do
      expect_raises(Exception) do
        dict = Libcv::BaseDict.load!("spec/_tests/nonexist.txt")
      end
    end
  end
end
