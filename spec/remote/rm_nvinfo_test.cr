require "file_utils"

require "../../src/source/rm_nvinfo.cr"

def fetch_info(sname, snvid, fresh = false) : Void
  puts "\n[#{CV::RmSpider.nvinfo_link(sname, snvid)}]".colorize.green.bold
  puts "------".colorize.green

  parser = CV::RmNvinfo.new(sname, snvid, ttl: fresh ? 1.minute : 1.year)

  nvinfo = {
    btitle: parser.btitle,
    author: parser.author,
    genres: parser.genres.join(" "),
    bintro: parser.bintro.join("\n"),
    bcover: parser.bcover,
    status: parser.status_int,
  }

  pp nvinfo
rescue err
  puts err.colorize.red
end

# fetch_info("qu_la", "7", fresh: false)
# fetch_info("qu_la", "9923", fresh: false)

fetch_info("jx_la", "7", fresh: false)
# fetch_info("jx_la", "179402", fresh: false)
# fetch_info("jx_la", "250502", fresh: false)
# fetch_info("jx_la", "80240", fresh: false)

fetch_info("69shu", "22729", fresh: false)
# fetch_info("69shu", "30062", fresh: true)

fetch_info("nofff", "18288", fresh: false)

fetch_info("rengshu", "181", fresh: false)

fetch_info("hetushu", "5", fresh: false)
fetch_info("hetushu", "4420", fresh: false)
# fetch_info("hetushu", "162", fresh: true)
# fetch_info("hetushu", "350", fresh: true)

fetch_info("duokan8", "6293", fresh: false)

fetch_info("xbiquge", "48680", fresh: false)
# fetch_info("xbiquge", "41881", fresh: true)

fetch_info("paoshu8", "817", fresh: false)

fetch_info("zhwenpg", "aun4tm", fresh: false)
# fetch_info("zhwenpg", "punj76", fresh: true)

fetch_info("5200", "28208", fresh: false)

fetch_info("bqg_5200", "139570", fresh: false)
# fetch_info("bqg_5200", "131878", fresh: true)

fetch_info("shubaow", "150092", fresh: false)

fetch_info("paoshu8", "151780", fresh: false)

fetch_info("69shu", "35875", fresh: false)
