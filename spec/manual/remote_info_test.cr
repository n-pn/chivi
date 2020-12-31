require "file_utils"

require "../../src/filedb/nvinit/rm_info.cr"

def fetch_info(seed, sbid, expiry = Time.utc - 1.month) : Void
  puts "\n[#{seed} - #{sbid}]\n".colorize.cyan.bold

  task = CV::RmInfo.init(seed, sbid, expiry)

  info = {
    btitle: task.btitle, author: task.author, bgenre: task.bgenre,
    intro: task.intro, cover: task.cover, tags: task.tags,
    status: task.status, update: task.update,
  }

  puts task.html_url
  puts "------".colorize.green

  pp info
  puts "------".colorize.green

  puts "chap_count: #{task.chlist.size}"
  puts "------".colorize.green

  pp task.chlist.first(4)
  puts "------".colorize.green

  pp task.chlist.last(4)
  puts "------".colorize.green
rescue err
  puts err.colorize.red
end

# fetch_info("qu_la", "7")
# fetch_info("qu_la", "9923")

# fetch_info("jx_la", "7")
# fetch_info("jx_la", "179402")
# fetch_info("jx_la", "250502")

fetch_info("69shu", "22729")
# fetch_info("69shu", "30062")

fetch_info("nofff", "18288")
fetch_info("rengshu", "181")

fetch_info("hetushu", "5")
# fetch_info("hetushu", "162")
# fetch_info("hetushu", "350")
# fetch_info("hetushu", "4420")

fetch_info("duokan8", "6293")
fetch_info("xbiquge", "48680")
# fetch_info("xbiquge", "41881")
fetch_info("paoshu8", "817")

fetch_info("zhwenpg", "aun4tm")
# fetch_info("zhwenpg", "punj76")

# fetch_info("jx_la", "80240")

fetch_info("5200", "28208")

# fetch_info("biquge5200", "139570")
fetch_info("shubaow", "150092")

fetch_info("biquge5200", "131878")
