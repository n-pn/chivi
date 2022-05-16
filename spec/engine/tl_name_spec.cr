require "spec"
require "../../src/libcv/tl_name"

tl_name = CV::TlName.new(CV::VpDict.new("spec/fixtures/dict.tsv"))

describe CV::TlName, tags: "tl_name" do
  it "keeps regular word meaning" do
    tl_name.tl_human("欧尼酱").should eq(["onii-chan", "Âu Ni-chan", "Âu Ni Tương"])
    tl_name.tl_human("圣索菲亚").should eq(["Thánh Sách Phi Á"])
    tl_name.tl_affil("中国").should eq(["Trung Quốc", "nước Trung"])
  end

  it "find defined values" do
    tl_name.tl_affil("中央银行").first.should eq("Ngân hàng Trung ương")
    tl_name.tl_affil("魏玛共和国").first.should eq("Cộng hoà Weimar")
  end

  it "keepd meaning for affil" do
    tl_name.tl_affil("帝国学院").first(1).should eq(["Học viện đế quốc"])
  end
end
