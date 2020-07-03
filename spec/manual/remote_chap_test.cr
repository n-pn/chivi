require "colorize"

require "../../src/import/remote_chap.cr"

def fetch_chap(seed : String, sbid : String, scid : String)
  puts "\n[ #{seed} / #{sbid} / #{scid} ]\n".colorize(:yellow)

  RemoteUtil.mkdir!(seed, sbid)
  chap = RemoteText.fetch!(seed, sbid, scid, freeze: true)

  puts chap.title
  puts chap.paras.first(5).join("\n")
end

fetch_chap("hetushu", "1640", "1099716")

fetch_chap("jx_la", "7", "3666")
fetch_chap("jx_la", "75722", "4089610")

fetch_chap("nofff", "6363", "23951830")
fetch_chap("69shu", "30062", "22447740")
fetch_chap("69shu", "30608", "22947405")

fetch_chap("rengshu", "4243", "1408503")
fetch_chap("xbiquge", "51918", "34575059")

fetch_chap("zhwenpg", "aun4tm", "521645")

fetch_chap("duokan8", "5255", "1412849")
fetch_chap("duokan8", "1986", "400011")

fetch_chap("paoshu8", "1986", "1447835")
