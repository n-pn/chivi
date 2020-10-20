require "../spec_helper"
require "../../src/engine/library/base_dict"

describe Engine::BaseDict do
  # TODO:
  # - Test dict preload and reload

  describe ".load" do
    it "loads empty dict" do
      dict = Engine::BaseDict.load!("spec/_tests/nonexist.txt")
      dict.should_not be(nil)

      dict.size.should eq(0)
    end

    it "loads existed dict" do
      dict = Engine::BaseDict.load!("spec/_tests/sample-lexfile.dic")
      dict.should_not be(nil)

      dict.size.should eq(1)
    end
  end

  describe ".load!" do
    it "should raise when file not found!" do
      expect_raises(Exception) do
        dict = Engine::BaseDict.load!("spec/_tests/nonexist.txt")
      end
    end
  end
end
