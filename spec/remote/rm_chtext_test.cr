require "colorize"

require "../../src/source/rm_chtext.cr"

def fetch_text(sname : String, snvid : String, schid : String, fresh = false)
  puts "\n[#{CV::RmSpider.chtext_link(sname, snvid, schid)}]\n".colorize.blue.bold

  chap = CV::RmChtext.new(sname, snvid, schid, ttl: fresh ? 1.minute : 10.years)

  puts chap.title
  puts "---".colorize.blue
  puts chap.paras.first(4).join("\n")
  puts "---".colorize.blue
  puts chap.paras.last(4).join("\n")
rescue err
  puts err.colorize.red
end

fetch_text("69shu", "30494", "22578503", fresh: false)

fetch_text("jx_la", "7", "3666", fresh: false)
# fetch_text("jx_la", "75722", "4089610")
# fetch_text("jx_la", "249305", "1725573")

fetch_text("nofff", "5906", "50749469", fresh: false)

fetch_text("rengshu", "4243", "1408503", fresh: false)

fetch_text("xbiquge", "51918", "34575059", fresh: false)
# fetch_text("xbiquge", "49022", "36025495")

fetch_text("zhwenpg", "aun4tm", "521645", fresh: false)

fetch_text("duokan8", "1986", "400011", fresh: false)
# fetch_text("duokan8", "5255", "1412849")
# fetch_text("duokan8", "14441", "8448980")

fetch_text("paoshu8", "1986", "1447835", fresh: false)

fetch_text("5200", "28208", "12163631", fresh: false)

fetch_text("bqg_5200", "139731", "174666986", fresh: false)
# fetch_text("bqg_5200", "131878", "174602931")

fetch_text("shubaow", "150092", "32706021", fresh: false)
# fetch_text("shubaow", "149926", "32662664")

fetch_text("hetushu", "5124", "3814265", fresh: false)

# fetch_text("qu_la", "7", "3382573")
# fetch_text("qu_la", "7", "3382447")

fetch_text("69shu", "35875", "25117266", fresh: false)

fetch_text("biqubao", "33775", "18804401", fresh: false)

fetch_text("bxwxorg", "119227", "1367374", fresh: false)
