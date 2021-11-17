require "./spec_helper"

require "../src/_util/*"

describe Utils do
  describe ".titleize" do
    it "works correctly" do
      Utils.titleize("xxx  x x").should eq("Xxx  X X")
    end
    it "can handle empty string" do
      Utils.titleize("").should eq("")
    end
  end

  describe ".han_to_int" do
    it "works correctly" do
      Utils.han_to_int("1203").should eq(1203)
      Utils.han_to_int("十").should eq(10)
      Utils.han_to_int("十七").should eq(17)
      Utils.han_to_int("二十").should eq(20)
      Utils.han_to_int("七十").should eq(70)
      Utils.han_to_int("二十七").should eq(27)
      Utils.han_to_int("百").should eq(100)
      Utils.han_to_int("百零五").should eq(105)
      Utils.han_to_int("百十五").should eq(115)
      Utils.han_to_int("百二十七").should eq(127)
      Utils.han_to_int("一百二十七").should eq(127)
      Utils.han_to_int("八百零五").should eq(805)
      Utils.han_to_int("八百三十五").should eq(835)
      Utils.han_to_int("四千零七").should eq(4007)
      Utils.han_to_int("四千八百零七").should eq(4807)
      Utils.han_to_int("四千二百一十七").should eq(4217)
      Utils.han_to_int("九九九〇").should eq(9990)
    end
  end
end
