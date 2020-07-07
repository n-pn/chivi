require "../spec_helper"
require "../../src/kernel/dict_repo"

describe DictRepo do
  # TODO:
  # - Test dict preload and reload

  describe ".load" do
    it "loads empty dict" do
      dict = DictRepo.load!("spec/_tests/nonexist.txt")
      dict.should_not be(nil)

      dict.size.should eq(0)
      dict.time.should eq(nil)
    end

    it "loads existed dict" do
      dict = DictRepo.load!("spec/_tests/sample-lexfile.dic")
      dict.should_not be(nil)

      dict.size.should eq(1)
      dict.time.should_not eq(nil)
    end
  end

  describe ".load!" do
    it "should raise when file not found!" do
      expect_raises(Exception) do
        dict = DictRepo.load!("spec/_tests/nonexist.txt")
      end
    end
  end
end
