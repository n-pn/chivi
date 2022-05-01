require "colorize"

require "../../src/_init/remote_text.cr"

def fetch_text(sname : String, snvid : String, schid : String, fresh = false)
  chap = CV::RemoteText.new(sname, snvid, schid, ttl: fresh ? 1.minute : 10.years)
  puts "\n[#{chap.link}]\n".colorize.blue.bold

  puts chap.title
  puts "---".colorize.blue
  puts chap.paras.first(4).join("\n")
  puts "---".colorize.blue
  puts chap.paras.last(4).join("\n")
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

fetch_text("69shu", "30494", "22578503", fresh: false)

fetch_text("jx_la", "7", "3666", fresh: false)
# fetch_text("jx_la", "75722", "4089610")
# fetch_text("jx_la", "249305", "1725573")

fetch_text("sdyfcm", "5906", "50749469", fresh: false)

fetch_text("rengshu", "4243", "1408503", fresh: false)

fetch_text("xbiquge", "51918", "34575059", fresh: false)
# fetch_text("xbiquge", "49022", "36025495")

fetch_text("zhwenpg", "aun4tm", "521645", fresh: false)

fetch_text("duokan8", "1986", "400011", fresh: false)
# fetch_text("duokan8", "5255", "1412849")
# fetch_text("duokan8", "14441", "8448980")

fetch_text("paoshu8", "1986", "1447835", fresh: false)

fetch_text("5200", "28208", "12163631", fresh: false)

fetch_text("biqu5200", "139731", "174666986", fresh: false)
# fetch_text("biqu5200", "131878", "174602931")

fetch_text("shubaow", "150092", "32706021", fresh: false)
# fetch_text("shubaow", "149926", "32662664")

# fetch_text("qu_la", "7", "3382573")
# fetch_text("qu_la", "7", "3382447")

fetch_text("69shu", "35875", "25117266", fresh: false)

fetch_text("biqugee", "33775", "18804401", fresh: false)

fetch_text("bxwxorg", "119227", "1367374", fresh: false)
# fetch_text("bxwxorg", "170826", "1399584", fresh: false)

# fetch_text("hetushu", "5124", "3814265", fresh: false)
# fetch_text("hetushu", "2421", "1655382", fresh: false)
fetch_text("hetushu", "1640", "1099716", fresh: false)

fetch_text("69shu", "35094", "24508034", fresh: false)

fetch_text("ptwxz", "1806", "803058", fresh: false)

fetch_text("biqugee", "51452", "649594", fresh: false)
fetch_text("biqugee", "57287", "538148", fresh: false)

fetch_text("biquyue", "56580", "63002", fresh: false)

fetch_text("xswang", "2028", "6718369", fresh: false)
