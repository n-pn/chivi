require "file_utils"

require "../../src/source/rm_info.cr"

def fetch_info(sname, snvid, fresh = false) : Void
  ::FileUtils.mkdir_p("_db/.cache/#{sname}/infos")

  puts "\n[#{CV::RmInfo.url_for(sname, snvid)}]".colorize.green.bold
  puts "------".colorize.green

  expiry = fresh ? Time.utc : Time.utc - 1.years
  parser = CV::RmInfo.init(sname, snvid, expiry)

  info = {
    btitle: parser.btitle,
    author: parser.author,
    genres: parser.genres.join(" "),
    bintro: parser.bintro.join("\n"),
    bcover: parser.bcover,
    status: parser.status_int,
    update: parser.updated_at,
  }

  pp info
  puts "------".colorize.green

  puts "chap_count: #{parser.chap_list.size}"
  puts "------".colorize.green

  parser.chap_list.first(4).map { |x| pp x }
  puts "------".colorize.green

  parser.chap_list.last(4).map { |x| pp x }
  puts "------".colorize.green
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

fetch_info("paoshu8", "151780", fresh: true)
