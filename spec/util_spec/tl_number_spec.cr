require "../spec_helper"
require "../../src/_util/tran_util/tl_number"

describe TlNumber do
  it "translate digits to digits" do
    TlNumber.translate("123").should eq("123")
    TlNumber.translate("１").should eq("1")
  end

  it "translate mixed letters to vietnamese with units" do
    TlNumber.translate("2百万").should eq("2 triệu")
    TlNumber.translate("2万4").should eq("24 nghìn")
    TlNumber.translate("２５百万").should eq("25 triệu")
  end

  it "translate chinese letters to vietnamese" do
    TlNumber.translate("六七").should eq("sáu bảy")
    TlNumber.translate("十七").should eq("mười bảy")
    TlNumber.translate("七十").should eq("bảy mươi")
    TlNumber.translate("六五").should eq("sáu năm")
    TlNumber.translate("十").should eq("mười")
    TlNumber.translate("十千").should eq("mười nghìn")
    TlNumber.translate("十万").should eq("trăm nghìn")

    TlNumber.translate("七十七").should eq("bảy mươi bảy")
    TlNumber.translate("六万七").should eq("sáu mươi bảy nghìn")

    # TlNumber.translate("六百七").should eq("sáu trăm bảy")
    TlNumber.translate("六七万").should eq("sáu bảy mươi nghìn")
    TlNumber.translate("六十七万").should eq("sáu trăm bảy mươi nghìn")
  end

  it "handle special 零/一/五/十 cases" do
    TlNumber.translate("一百零三").should eq("một trăm linh ba")
    TlNumber.translate("一百一十六").should eq("một trăm mười sáu")
    TlNumber.translate("一百二十七").should eq("một trăm hai mươi bảy")
    TlNumber.translate("一千一百零三").should eq("một nghìn một trăm linh ba")

    TlNumber.translate("七十一").should eq("bảy mươi mốt")
    TlNumber.translate("六十五").should eq("sáu mươi lăm")
    TlNumber.translate("五十五").should eq("năm mươi lăm")
    TlNumber.translate("六万五").should eq("sáu mươi lăm nghìn")
    TlNumber.translate("五百一十五").should eq("năm trăm mười lăm")
  end

  it "translate mixed chinese letters and digits to vietnamese" do
    TlNumber.translate("１2七8").should eq("12 bảy 8")
    TlNumber.translate("六12七8").should eq("sáu 12 bảy 8")

    TlNumber.translate("1万").should eq("10 nghìn")
    TlNumber.translate("1万6千").should eq("16 nghìn")
    TlNumber.translate("1万6百").should eq("10 nghìn 6 trăm")
  end

  it "translate chinese letters to digits" do
    TlNumber.translate("100", scale: 1).should eq("100")
    TlNumber.translate("１", scale: 1).should eq("1")

    TlNumber.translate("一百零三", scale: 1).should eq("103")
    TlNumber.translate("一百一十六", scale: 1).should eq("116")
    TlNumber.translate("一百二十七", scale: 1).should eq("127")
    TlNumber.translate("一千一百零三", scale: 1).should eq("1103")

    TlNumber.translate("2百", scale: 1).should eq("200")
    TlNumber.translate("2万", scale: 1).should eq("20000")
    TlNumber.translate("2百万", scale: 1).should eq("2000000")
    TlNumber.translate("2万5", scale: 1).should eq("25000")
    TlNumber.translate("25百万", scale: 1).should eq("25000000")

    TlNumber.translate("1万6百", scale: 1).should eq("10600")

    TlNumber.translate("十七", scale: 1).should eq("17")
    TlNumber.translate("六七", scale: 1).should eq("67")
    TlNumber.translate("12七", scale: 1).should eq("127")
    TlNumber.translate("１2七8", scale: 1).should eq("1278")
    TlNumber.translate("六12七8", scale: 1).should eq("61278")

    TlNumber.translate("十千", scale: 1).should eq("10000")
    TlNumber.translate("六万七千", scale: 1).should eq("67000")
  end
end

test = {
  "1万",
  "1万6千",
  "2万6千",
  "1万6百",
  "六七万",
  "六十七万",
  "七十万",
  "十万",
  "十千",
}
test.each do |item|
  puts "#{item} => [#{TlNumber.translate(item, scale: 1)}] [#{TlNumber.translate(item)}]"
end
