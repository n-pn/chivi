require "../spec_helper"
require "../../src/mt_ai/util/qt_number"

describe MT::QtNumber do
  it "translate digits to digits" do
    MT::QtNumber.translate("123").should eq("123")
    MT::QtNumber.translate("１").should eq("1")
  end

  it "translate mixed letters to vietnamese with units" do
    MT::QtNumber.translate("2百万").should eq("2 triệu")
    MT::QtNumber.translate("2万4").should eq("24 nghìn")
    MT::QtNumber.translate("２５百万").should eq("25 triệu")
  end

  it "translate chinese letters to vietnamese" do
    MT::QtNumber.translate("六七").should eq("sáu bảy")
    MT::QtNumber.translate("十七").should eq("mười bảy")
    MT::QtNumber.translate("七十").should eq("bảy mươi")
    MT::QtNumber.translate("六五").should eq("sáu năm")
    MT::QtNumber.translate("十").should eq("mười")
    MT::QtNumber.translate("十千").should eq("mười nghìn")
    MT::QtNumber.translate("十万").should eq("trăm nghìn")

    MT::QtNumber.translate("七十七").should eq("bảy mươi bảy")
    MT::QtNumber.translate("六万七").should eq("sáu mươi bảy nghìn")

    # MT::QtNumber.translate("六百七").should eq("sáu trăm bảy")
    MT::QtNumber.translate("六七万").should eq("sáu bảy mươi nghìn")
    MT::QtNumber.translate("六十七万").should eq("sáu trăm bảy mươi nghìn")
  end

  it "handle special 零/一/五/十 cases" do
    MT::QtNumber.translate("一百零三").should eq("một trăm linh ba")
    MT::QtNumber.translate("一百一十六").should eq("một trăm mười sáu")
    MT::QtNumber.translate("一百二十七").should eq("một trăm hai mươi bảy")
    MT::QtNumber.translate("一千一百零三").should eq("một nghìn một trăm linh ba")

    MT::QtNumber.translate("七十一").should eq("bảy mươi mốt")
    MT::QtNumber.translate("六十五").should eq("sáu mươi lăm")
    MT::QtNumber.translate("五十五").should eq("năm mươi lăm")
    MT::QtNumber.translate("六万五").should eq("sáu mươi lăm nghìn")
    MT::QtNumber.translate("五百一十五").should eq("năm trăm mười lăm")
  end

  it "translate mixed chinese letters and digits to vietnamese" do
    MT::QtNumber.translate("１2七8").should eq("12 bảy 8")
    MT::QtNumber.translate("六12七8").should eq("sáu 12 bảy 8")

    MT::QtNumber.translate("1万").should eq("10 nghìn")
    MT::QtNumber.translate("1万6千").should eq("16 nghìn")
    MT::QtNumber.translate("1万6百").should eq("10 nghìn 6 trăm")
  end

  it "translate chinese letters to digits" do
    MT::QtNumber.translate("100", :pure_digit).should eq("100")
    MT::QtNumber.translate("１", :pure_digit).should eq("1")

    MT::QtNumber.translate("一百零三", :pure_digit).should eq("103")
    MT::QtNumber.translate("一百一十六", :pure_digit).should eq("116")
    MT::QtNumber.translate("一百二十七", :pure_digit).should eq("127")
    MT::QtNumber.translate("一千一百零三", :pure_digit).should eq("1103")

    MT::QtNumber.translate("2百", :pure_digit).should eq("200")
    MT::QtNumber.translate("2万", :pure_digit).should eq("20000")
    MT::QtNumber.translate("2百万", :pure_digit).should eq("2000000")
    MT::QtNumber.translate("2万5", :pure_digit).should eq("25000")
    MT::QtNumber.translate("25百万", :pure_digit).should eq("25000000")

    MT::QtNumber.translate("1万6百", :pure_digit).should eq("10600")

    MT::QtNumber.translate("十七", :pure_digit).should eq("17")
    MT::QtNumber.translate("六七", :pure_digit).should eq("67")
    MT::QtNumber.translate("12七", :pure_digit).should eq("127")
    MT::QtNumber.translate("１2七8", :pure_digit).should eq("1278")
    MT::QtNumber.translate("六12七8", :pure_digit).should eq("61278")

    MT::QtNumber.translate("十千", :pure_digit).should eq("10000")
    MT::QtNumber.translate("六万七千", :pure_digit).should eq("67000")
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
  puts "#{item} => [#{MT::QtNumber.translate(item, :pure_digit)}] [#{MT::QtNumber.translate(item)}]"
end
