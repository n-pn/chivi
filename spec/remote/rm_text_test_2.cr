require "colorize"

require "../../src/wnapp/remote/rm_text.cr"
require "../../src/_util/site_link"

def fetch_text(sname : String, s_bid : Int32, s_cid : Int32, reset = false)
  link = SiteLink.text_url(sname, s_bid, s_cid)
  puts "\n[#{link.colorize.blue.bold}]"

  chap = WN::RmText.new(link, ttl: reset ? 2.minutes : 10.years)
  puts

  puts chap.bname.colorize.yellow
  puts "---".colorize.dark_gray
  puts chap.title.colorize.green
  puts "---".colorize.dark_gray
  puts chap.paras.first(4).join("\n")
  puts "---".colorize.dark_gray
  puts chap.paras.last(4).join("\n")
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

fetch_text("uukanshu", 33933, 55150, reset: false)

fetch_text("69shu", 30494, 22578503, reset: false)

# fetch_text("rengshu", 4243, 1408503, reset: false)

fetch_text("xbiquge", 51918, 34575059, reset: false)
# fetch_text("xbiquge", 49022, 36025495)

# fetch_text("duokan8", 1986, 400011, reset: false)
# fetch_text("duokan8", 5255, 1412849)
# fetch_text("duokan8", 14441, 8448980)

fetch_text("paoshu8", 1986, 1447835, reset: false)

# fetch_text("5200", 28208, 12163631, reset: false)

fetch_text("biqu5200", 139731, 174666986, reset: false)
# fetch_text("biqu5200", 131878, 174602931)

# fetch_text("shubaow", 150092, 32706021, reset: false)
# fetch_text("shubaow", 149926, 32662664)

# fetch_text("biqugee", 33775, 18804401, reset: false)

# fetch_text("bxwxorg", 119227, 1367374, reset: false)

fetch_text("hetushu", 1640, 1099716, reset: false)

fetch_text("69shu", 35094, 24508034, reset: false)

fetch_text("ptwxz", 1806, 803058, reset: false)

# fetch_text("biqugee", 51452, 649594, reset: false)

fetch_text("biqu5200", 153174, 180388551, reset: false)

# fetch_text("133txt", 9, 5900, reset: false)

# fetch_text("biqugse", 69761, 95223327, reset: false)
# fetch_text("bqxs520", 122958, 95416098, reset: false)

fetch_text("b5200", 160872, 183484031, reset: false)
fetch_text("bxwxio", 127400, 52941263, reset: false)

# fetch_text("uuks", 23389, 292361, reset: false)
# fetch_text("yannuozw", 147108, 69474701, reset: false)

# fetch_text("kanshu8", 59127, 47845259, reset: false)
fetch_text("69shu", 37960, 29004701, reset: true)
