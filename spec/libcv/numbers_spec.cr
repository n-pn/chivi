require "spec"
require "../../src/libcv/mt_core"

MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

macro test_eq(left, right)
  convert({{left}}).should eq({{right}})
end

describe CV::TlRule do
  describe "combine numbers" do
    it "returns same numbers for latin number" do
      test_eq "1", "1"
      test_eq "12", "12"
      test_eq "99", "99"
    end

    it "can handle . notion" do
      test_eq "1.2", "1.2"
      test_eq "133.2", "133.2"
      test_eq "xx 133.2", "xx 133.2"
      test_eq "133.2 xx", "133.2 xx"
      test_eq "xx 133.2 xx", "xx 133.2 xx"
    end

    it "can handle d:d notion" do
      test_eq "1:12", "1:12"
      test_eq "1:12 xx", "1:12 xx"
      test_eq "xx 1:12", "xx 1:12"
      test_eq "xx 1:12 xx", "xx 1:12 xx"
    end

    it "can handle d:d:d notion" do
      test_eq "13:3:2", "13:3:2"
    end

    it "can combine hanzi number" do
      test_eq "九点九", "chín chấm chín"
      test_eq "九十点九", "chín mươi chấm chín"
      test_eq "九十九点九九", "chín mươi chín chấm chín chín"
    end
  end

  describe "百分之" do
    it "=> chín phần trăm" do
      test_eq "百分之九", "chín phần trăm"
    end

    it "=> chín mươi phần trăm" do
      test_eq "百分之九十", "chín mươi phần trăm"
    end

    it "=> chín mươi chín phần trăm" do
      test_eq "百分之九十九", "chín mươi chín phần trăm"
    end

    it "=> chín mươi chín chấm chín chín phần trăm" do
      test_eq "百分之九十九点九九", "chín mươi chín chấm chín chín phần trăm"
    end
  end
end
