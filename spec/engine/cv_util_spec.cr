require "../spec_helper"
require "../../src/engine/cv_util"

include Engine::CvUtil

describe Engine::CvUtil do
  # include Engine::CvUtil

  describe ".titleize" do
    it "works correctly" do
      titleize("xxx  x x").should eq("Xxx  X X")
    end
    it "can handle empty string" do
      titleize("").should eq("")
    end
  end

  describe ".hanzi_int" do
    it "works correctly" do
      hanzi_int("1203").should eq(1203)
      hanzi_int("十").should eq(10)
      hanzi_int("十七").should eq(17)
      hanzi_int("二十").should eq(20)
      hanzi_int("七十").should eq(70)
      hanzi_int("二十七").should eq(27)
      hanzi_int("百").should eq(100)
      hanzi_int("百零五").should eq(105)
      hanzi_int("百十五").should eq(115)
      hanzi_int("百二十七").should eq(127)
      hanzi_int("一百二十七").should eq(127)
      hanzi_int("八百零五").should eq(805)
      hanzi_int("八百三十五").should eq(835)
      hanzi_int("四千零七").should eq(4007)
      hanzi_int("四千八百零七").should eq(4807)
      hanzi_int("四千二百一十七").should eq(4217)
      hanzi_int("九九九〇").should eq(9990)
    end
  end
end
