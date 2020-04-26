require "../spec_helper"
require "../../src/engine/cv_util"

describe CvUtil do
  describe ".titleize" do
    it "works correctly" do
      CvUtil.titleize("xxx  x x").should eq("Xxx  X X")
    end
    it "can handle empty string" do
      CvUtil.titleize("").should eq("")
    end
  end

  describe ".hanzi_int" do
    it "works correctly" do
      CvUtil.hanzi_int("1203").should eq(1203)
      CvUtil.hanzi_int("十").should eq(10)
      CvUtil.hanzi_int("十七").should eq(17)
      CvUtil.hanzi_int("二十").should eq(20)
      CvUtil.hanzi_int("七十").should eq(70)
      CvUtil.hanzi_int("二十七").should eq(27)
      CvUtil.hanzi_int("百").should eq(100)
      CvUtil.hanzi_int("百零五").should eq(105)
      CvUtil.hanzi_int("百十五").should eq(115)
      CvUtil.hanzi_int("百二十七").should eq(127)
      CvUtil.hanzi_int("一百二十七").should eq(127)
      CvUtil.hanzi_int("八百零五").should eq(805)
      CvUtil.hanzi_int("八百三十五").should eq(835)
      CvUtil.hanzi_int("四千零七").should eq(4007)
      CvUtil.hanzi_int("四千八百零七").should eq(4807)
      CvUtil.hanzi_int("四千二百一十七").should eq(4217)
      CvUtil.hanzi_int("九九九〇").should eq(9990)
    end
  end
end
