require "colorize"

require "../../src/kernel/source/seed_text.cr"

def fetch_chap(seed : String, sbid : String, scid : String)
  puts "\n[ #{seed}/#{sbid}/#{scid} ]\n".colorize(:yellow)

  chap = SeedText.init(seed, sbid, scid, freeze: true)

  puts chap.title
  puts "---"
  puts chap.paras.first(4).join("\n")
  puts "---"
  puts chap.paras.last(4).join("\n")
end

# fetch_chap("hetushu", "1640", "1099716")

# fetch_chap("jx_la", "7", "3666")
# fetch_chap("jx_la", "75722", "4089610")
# fetch_chap("jx_la", "249305", "1725573")

# fetch_chap("nofff", "6363", "23951830")
# fetch_chap("69shu", "30062", "22447740")
# fetch_chap("69shu", "30608", "22947405")

# fetch_chap("rengshu", "4243", "1408503")
# fetch_chap("xbiquge", "51918", "34575059")
# fetch_chap("xbiquge", "49022", "36025495")

# fetch_chap("zhwenpg", "aun4tm", "521645")

# fetch_chap("duokan8", "1986", "400011")
# fetch_chap("duokan8", "5255", "1412849")
# fetch_chap("duokan8", "14441", "8448980")

# fetch_chap("paoshu8", "1986", "1447835")

# fetch_chap("qu_la", "7", "3382573")
# fetch_chap("qu_la", "7", "3382447")

# fetch_chap("5200", "28208", "12163631")

# fetch_chap("biquge5200", "139731", "174666986")

# fetch_chap("shubaow", "150092", "32706021")
fetch_chap("shubaow", "149926", "32662664")

# fetch_chap("biquge5200", "131878", "174602931")
