require "colorize"

require "../../src/import/remote_text.cr"

def fetch_text(seed : String, sbid : String, scid : String)
  puts "\n[ #{seed} / #{sbid} / #{scid} ]\n".colorize(:yellow)

  RemoteUtil.mkdir!(seed, sbid)
  text = RemoteText.fetch!(seed, sbid, scid, freeze: true)

  puts text.title
  puts text.paras.first(5).join("\n")
end

fetch_text("hetushu", "1640", "1099716")

fetch_text("jx_la", "7", "3666")
fetch_text("jx_la", "75722", "4089610")

fetch_text("nofff", "6363", "23951830")
fetch_text("69shu", "30062", "22447740")
fetch_text("69shu", "30608", "22947405")

fetch_text("rengshu", "4243", "1408503")
fetch_text("xbiquge", "51918", "34575059")

fetch_text("zhwenpg", "aun4tm", "521645")

fetch_text("duokan8", "5255", "1412849")
fetch_text("duokan8", "1986", "400011")

fetch_text("paoshu8", "1986", "1447835")
