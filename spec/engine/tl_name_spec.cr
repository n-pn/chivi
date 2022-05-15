require "spec"
require "../../src/libcv/tl_name"

tl_name = CV::TlName.new(CV::VpDict.new("spec/fixtures/dict.tsv"))

describe CV::TlName, tags: "tl_name" do
  it "keeps regular word meaning" do
    tl_name.tl_affil("中国").should eq(["Trung Quốc", "nước Trung"])
    tl_name.tl_human("欧尼酱").should eq(["onii-chan", "Âu Ni-chan", "Âu Ni Tương"])
  end
end
