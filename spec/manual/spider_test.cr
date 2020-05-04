require "../../src/spider/info_spider.cr"
require "../../src/spider/text_spider.cr"

def test_info(site, bsid, expiry = 6.hours) : Void
  spider = InfoSpider.load(site, bsid, expiry: expiry, frozen: true)

  puts spider.get_infos!.to_pretty_json
  puts spider.get_chaps!.first(10).to_pretty_json
end

def test_text(site, bsid, csid, expiry = 1000.hours)
  spider = TextSpider.load(site, bsid, csid, expiry: expiry, frozen: true)

  puts spider.get_title!
  puts spider.get_paras!.first(10).join("\n")
end

# test_info("jx_la", "15000")
# test_info("nofff", "18288")
# test_info("rengshu", "181")
# test_info("xbiquge", "51918")
# test_info("hetushu", "5")
# test_info("hetushu", "4420")
# test_info("duokan8", "6293")
# test_info("paoshu8", "1986")
# test_info("69shu", "30062")
# test_info("zhwenpg", "junthn")

test_text("jx_la", "7", "3666")
# test_text("jx_la", "75722", "4089610")
# test_text("jx_la", "101533", "5208291")
# test_text("nofff", "6363", "23951830")
# test_text("69shu", "30062", "22206999")
# test_text("hetushu", "1640", "1099716")
# test_text("rengshu", "4243", "1408503")
# test_text("xbiquge", "51918", "34575059")
# test_text("zhwenpg", "aun4tm", "521645")
# test_text("duokan8", "5255", "1412849")
# test_text("duokan8", "1986", "400011")
# test_text("paoshu8", "1986", "1447835")
# test_text("hetushu", "1640", "1099716")
