require "./_helper"

describe CV::TlRule do
  describe "convert number rule to time" do
    it "convert time" do
      assert_eq "早上6点", "6 giờ sáng"
      assert_eq "下午7点", "7 giờ chiều"

      assert_eq "三点前后", "tầm ba giờ"

      assert_eq "早上三点", "ba giờ sáng"
      assert_eq "下午三点", "ba giờ chiều"

      assert_eq "早上6点半", "6 giờ rưỡi sáng"
      assert_eq "下午7点半", "7 giờ rưỡi chiều"

      assert_eq "早上三点半", "ba giờ rưỡi sáng"
      assert_eq "下午三点半", "ba giờ rưỡi chiều"

      assert_eq "6点45", "6 giờ 45"
      assert_eq "6点45分", "6 giờ 45 phút"
    end
  end
end
