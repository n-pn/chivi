require "colorize"

require "../../src/filedb/_inits/rm_text.cr"

def fetch_chap(s_name : String, s_nvid : String, s_chid : String, fresh = false)
  puts "\n[#{CV::RmText.url_for(s_name, s_nvid, s_chid)}]\n".colorize.blue.bold

  expiry = fresh ? Time.utc : Time.utc - 1.years
  chap = CV::RmText.init(s_name, s_nvid, s_chid, expiry: expiry)

  puts chap.title
  puts "---".colorize.blue
  puts chap.paras.first(4).join("\n")
  puts "---".colorize.blue
  puts chap.paras.last(4).join("\n")
rescue err
  puts err.colorize.red
end

fetch_chap("69shu", "30494", "22578503", fresh: false)

fetch_chap("jx_la", "7", "3666", fresh: false)
# fetch_chap("jx_la", "75722", "4089610")
# fetch_chap("jx_la", "249305", "1725573")

fetch_chap("nofff", "5906", "50749469", fresh: false)

fetch_chap("rengshu", "4243", "1408503", fresh: false)

fetch_chap("xbiquge", "51918", "34575059", fresh: false)
# fetch_chap("xbiquge", "49022", "36025495")

fetch_chap("zhwenpg", "aun4tm", "521645", fresh: false)

fetch_chap("duokan8", "1986", "400011", fresh: false)
# fetch_chap("duokan8", "5255", "1412849")
# fetch_chap("duokan8", "14441", "8448980")

fetch_chap("paoshu8", "1986", "1447835", fresh: false)

fetch_chap("5200", "28208", "12163631", fresh: false)

fetch_chap("bqg_5200", "139731", "174666986", fresh: false)
# fetch_chap("bqg_5200", "131878", "174602931")

fetch_chap("shubaow", "150092", "32706021", fresh: false)
# fetch_chap("shubaow", "149926", "32662664")

fetch_chap("hetushu", "5124", "3814265", fresh: false)

# fetch_chap("qu_la", "7", "3382573")
# fetch_chap("qu_la", "7", "3382447")
