require "./_helper"

describe CV::TlRule do
  describe "convert number rule to time" do
    it "convert time" do
      assert_eq "早上6点", "6 giờ sáng"
      assert_eq "下午7点", "7 giờ chiều"

      assert_eq "三点半", "ba giờ rưỡi"

      assert_eq "三点前后", "tầm ba giờ"

      assert_eq "三点三分", "ba giờ ba phút"
      assert_eq "三点三分钟", "ba giờ ba phút"

      assert_eq "三点三分三秒", "ba giờ ba phút ba giây"
      assert_eq "三点三分钟三秒钟", "ba giờ ba phút ba giây"

      assert_eq "三分三秒", "ba phút ba giây"
      assert_eq "三分钟三秒钟", "ba phút ba giây"

      assert_eq "早上三点", "ba giờ sáng"
      assert_eq "下午三点", "ba giờ chiều"

      assert_eq "早上6点半", "6 giờ rưỡi sáng"
      assert_eq "下午7点半", "7 giờ rưỡi chiều"

      assert_eq "早上三点半", "ba giờ rưỡi sáng"
      assert_eq "下午三点半", "ba giờ rưỡi chiều"

      assert_eq "6点45", "6 giờ 45"
      assert_eq "6点45分", "6 giờ 45 phút"
      assert_eq "6点45分钟", "6 giờ 45 phút"
      assert_eq "6点45分15秒", "6 giờ 45 phút 15 giây"
    end
  end
end
