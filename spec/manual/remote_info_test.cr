require "file_utils"

require "../../src/parser/seed_info.cr"

def fetch_info(info, sbid, expiry = 30.days) : Void
  puts "\n[ #{info} / #{sbid} ]\n".colorize(:yellow)

  RemoteUtil.mkdir!(info)
  task = SeedInfo.new(info, sbid, expiry: expiry, freeze: true)

  puts task.emit_book_info.to_pretty_json
  puts task.latest_chap.to_pretty_json
  puts task.emit_chap_list(mode: :check).chaps.last(4).to_pretty_json
end

# fetch_info("jx_la", "7")
# fetch_info("jx_la", "179402")
fetch_info("jx_la", "250502")

# fetch_info("69shu", "22729")
# fetch_info("69shu", "30062")

# fetch_info("nofff", "18288")
# fetch_info("rengshu", "181")

# fetch_info("hetushu", "5")
# fetch_info("hetushu", "350")
# fetch_info("hetushu", "4420")

# fetch_info("duokan8", "6293")
fetch_info("xbiquge", "51918")
# fetch_info("xbiquge", "41881")
# fetch_info("paoshu8", "817")

# fetch_info("zhwenpg", "aun4tm")
# fetch_info("zhwenpg", "kun6m7")
