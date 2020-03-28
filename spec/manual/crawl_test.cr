require "../../src/crawls/cr_info.cr"

# require "./text-crawler"

def test_info(site, bsid)
  crawler = CrInfo.new(site, bsid)

  crawler.crawl!(persist: false)
  puts crawler.serial.to_pretty_json
  puts crawler.chlist.first(8).to_pretty_json
end

# test_info("jx_la", "156")
# test_info("nofff", "18288")
# test_info("rengshu", "181")
# test_info("xbiquge", "51918")
# test_info("hetushu", "5")
# test_info("duokan8", "6293")
# test_info("paoshu8", "1986")
# test_info("69shu", "30062")
# test_info("zhwenpg", "duny4q")

# puts Crawl::Text.new("jx_la", "7", "3666").crawl!(persist: false)
# puts Crawl::Text.new("jx_la", "101533", "5208291").crawl!(persist: false)
# puts Crawl::Text.new("nofff", "6363", "23951830").crawl!(persist: false)
# puts Crawl::Text.new("69shu", "29973", "21120847").crawl!(persist: false)
# puts Crawl::Text.new("hetushu", "1619", "1087468").crawl!(persist: false)
# puts Crawl::Text.new("rengshu", "4243", "1408503").crawl!(persist: false)
# puts Crawl::Text.new("xbiquge", "51918", "34575059").crawl!(persist: false)
# puts Crawl::Text.new("zhwenpg", "aun4tm", "521645").crawl!(persist: false)
# puts Crawl::Text.new("duokan8", "1986", "400011").crawl!(persist: true)
# puts Crawl::Text.new("paoshu8", "1986", "1447835").crawl!(persist: true)

# puts Crawl::Text.new("duokan8", "5255", "1412849").crawl!(persist: false)

# crawler = CrInfo.new("rengshu", "65")
# # File.delete(crawler.chap_file) if File.exists?(crawler.chap_file)
# crawler.crawl!(persist: true)

# puts crawler.chapters.to_pretty_json

# crawler = Crawl::Text.new("jx_la", "75722", "4089610")
# # crawler = Crawl::Text.new("jx_la", "7", "3666")

# crawler.crawl!(persist: false)

# puts crawler.title
# puts crawler.paras
