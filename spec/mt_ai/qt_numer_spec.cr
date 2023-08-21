require "../spec_helper"
require "../../src/mt_ai/util/qt_number"

describe AI::QtNumber do
  it "translate digits to digits" do
    AI::QtNumber.translate("123").should eq("123")
    AI::QtNumber.translate("１").should eq("1")
  end

  it "translate mixed letters to vietnamese with units" do
    AI::QtNumber.translate("2百万").should eq("2 triệu")
    AI::QtNumber.translate("２５百万").should eq("25 triệu")
  end

  it "translate chinese letters to vietnamese" do
    AI::QtNumber.translate("六七").should eq("sáu bảy")
    AI::QtNumber.translate("12七").should eq("12 bảy")
    AI::QtNumber.translate("１2七8").should eq("12 bảy 8")
    AI::QtNumber.translate("六12七8").should eq("sáu 12 bảy 8")
  end

  it "translate chinese letters to digits" do
    AI::QtNumber.translate("六七", true).should eq("67")
    AI::QtNumber.translate("12七", true).should eq("127")
    AI::QtNumber.translate("１2七8", true).should eq("1278")
    AI::QtNumber.translate("六12七8", true).should eq("61278")
  end
end

test = {
  "六七",
  "123",
  "12七",
  "12七8",
  "六12七8",

  "2百万",
  "25百万",
  "1万",
  "1万6千",
  "2万6千",
  "1万6百",
  "六七万",
  "六十七万",
  "七十万",
  "十万",
  "十千",
  "六万七千",
  "十七",
  "１",
  "第八十一",
}
test.each do |item|
  puts "#{item} => [#{AI::QtNumber.translate(item, true)}] [#{AI::QtNumber.translate(item, false)}]"
end
