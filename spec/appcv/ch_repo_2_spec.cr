require "spec"

require "../../src/appcv/ch_repo_2"

describe CV::ChRepo2 do
  repo = CV::ChRepo2.new("zxcs_me", 308)

  it "loads correctly" do
    repo.count.should eq 1316
  end

  it "find a single entry" do
    repo.get(1).should be_a(CV::ChInfo2)
  end

  it "return nil on missing entry" do
    repo.get(100000).should be_a(Nil)
  end

  it "read title from entry" do
    repo.get_title(2).should eq("第2章 医院")
  end

  it "find the matching ch_no from title" do
    repo.match_ch_no("第2章 医院", 1).should eq(2)
  end
end
