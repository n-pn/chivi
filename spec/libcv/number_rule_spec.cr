require "spec"
require "../../src/libcv/mt_core"

MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

describe CV::TlRule do
  describe "百分之" do
    it "=> chín phần trăm" do
      convert("百分之九").should eq("chín phần trăm")
    end

    it "=> chín mươi phần trăm" do
      convert("百分之九十").should eq("chín mươi phần trăm")
    end

    it "=> chín mươi chín phần trăm" do
      convert("百分之九十九").should eq("chín mươi chín phần trăm")
    end

    it "=> chín mươi chín chấm chín chín phần trăm" do
      convert("百分之九十九点九九").should eq("chín mươi chín chấm chín chín phần trăm")
    end
  end
end
