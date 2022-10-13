require "spec"
require "../../src/cvmtl/tl_name"

tl_name = CV::TlName.new(CV::VpDict.new("spec/fixtures/dict.tsv"))

describe CV::TlName, tags: "tl_name" do
  it "keeps regular word meaning" do
    tl_name.tl_affil("中国").first.should eq("Trung Quốc")
    tl_name.tl_human("欧尼酱").first.should eq("onii-chan")
    tl_name.tl_human("圣索菲亚").should eq(["Thánh Sách Phi Á"])
  end

  it "correctly translate human names" do
    tl_name.tl_human("黑铁妖王").should eq(["Hắc Thiết yêu vương", "Hắc Thiết Yêu Vương"])
  end

  it "find defined values" do
    tl_name.tl_affil("中央银行").first.should eq("ngân hàng trung ương")
    tl_name.tl_affil("魏玛共和国").first.should eq("Cộng hoà Weimar")
  end

  it "keepd meaning for affil" do
    tl_name.tl_affil("帝国学院").first(1).should eq(["Học viện đế quốc"])
  end
end
