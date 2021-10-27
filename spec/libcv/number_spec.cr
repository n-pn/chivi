require "./_helper"

describe CV::TlRule do
  describe "combine numbers" do
    it "returns same numbers for latin number" do
      assert_eq "1", "1"
      assert_eq "12", "12"
      assert_eq "99", "99"
    end

    it "can handle . notion" do
      assert_eq "1.2", "1.2"
      assert_eq "133.2", "133.2"
      assert_eq "xx 133.2", "xx 133.2"
      assert_eq "133.2 xx", "133.2 xx"
      assert_eq "xx 133.2 xx", "xx 133.2 xx"
    end

    it "can handle d:d notion" do
      assert_eq "1:12", "1:12"
      assert_eq "1:12 xx", "1:12 xx"
      assert_eq "xx 1:12", "xx 1:12"
      assert_eq "xx 1:12 xx", "xx 1:12 xx"
    end

    it "can handle d:d:d notion" do
      assert_eq "13:3:2", "13:3:2"
    end

    it "can combine hanzi number" do
      assert_eq "九点九", "chín chấm chín"
      assert_eq "九十点九", "chín mươi chấm chín"
      assert_eq "九十九点九九", "chín mươi chín chấm chín chín"
    end
  end

  describe "百分之" do
    it "=> chín phần trăm" do
      assert_eq "百分之九", "chín phần trăm"
    end

    it "=> chín mươi phần trăm" do
      assert_eq "百分之九十", "chín mươi phần trăm"
    end

    it "=> chín mươi chín phần trăm" do
      assert_eq "百分之九十九", "chín mươi chín phần trăm"
    end

    it "=> chín mươi chín chấm chín chín phần trăm" do
      assert_eq "百分之九十九点九九", "chín mươi chín chấm chín chín phần trăm"
    end
  end

  describe "handling approximate" do
    it "folds 多" do
      assert_eq "三百多", "hơn ba trăm"
      assert_eq "三百多万", "hơn ba trăm vạn"
    end

    it "folds 来" do
      assert_eq "二十来", "chừng hai mươi"
      assert_eq "三百来万", "chừng ba trăm vạn"
      assert_eq "十来", "mười đến"
    end

    it "folds 余" do
      assert_eq "二百余", "trên hai trăm"
      assert_eq "二十余万", "trên hai mươi vạn"
      assert_eq "十余", "trên mười"
    end

    it "folds 几" do
      assert_eq "三百几", "ba trăm mấy"
      assert_eq "三百几万", "ba trăm mấy vạn"
      assert_eq "十几", "mười mấy"
      assert_eq "几十", "mấy mươi"
    end
  end
end
