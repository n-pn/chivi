require "./_helper"

macro assert_eq(left, right)
  CV::PosTag.parse("m", {{left}}).should eq(CV::PosTag::{{right}})
end

describe CV::PosTag do
  describe "mapping numbers" do
    it "correcty map latin numbers" do
      assert_eq "1", Ndigit
      assert_eq "12", Ndigit
      assert_eq "12.4", Number
    end

    it "correcty map hanzi numbers" do
      assert_eq "二", Nhanzi
      assert_eq "万万", Nhanzi
      assert_eq "八九.八", Number
      assert_eq "八九点八", Number
      assert_eq "茫茫多", Number
    end
  end
end
