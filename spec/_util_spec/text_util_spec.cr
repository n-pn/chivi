require "../spec_helper"
require "../../src/_util/text_util"

def unaccent(input)
  TextUtil.unaccent(input)
end

describe TextUtil do
  describe ".titleize" do
    it "works correctly" do
      TextUtil.titleize("xxx  x x").should eq("Xxx  X X")
    end
    it "can handle empty string" do
      TextUtil.titleize("").should eq("")
    end
  end

  describe ".unaccent" do
    it "works correctly" do
      unaccent("Thêm truyện mới").should eq("them truyen moi")
    end

    it "converts `Đđ` to `d`" do
      unaccent("Đoàn đội").should eq("doan doi")
    end
  end
end
