require "file_utils"

require "../../src/seeds/rm_info.cr"

def fetch_info(sname, snvid, fresh = false) : Void
  puts "\n[#{CV::SiteLink.binfo_url(sname, snvid)}]".colorize.green.bold
  parser = CV::RmInfo.init(sname, snvid, ttl: fresh ? 10.seconds : 1.year)

  puts "------".colorize.green

  output = {
    btitle: parser.btitle,
    author: parser.author,
    genres: parser.genres.join(" "),
    bintro: parser.bintro.join("\n"),
    bcover: parser.bcover,
    status: parser.status,
    update: parser.update,

    last_schid: parser.last_schid,
  }

  pp output

  puts "------".colorize.green

  puts "chap_count: #{parser.chap_list.size}"
  puts "last_schid: #{parser.last_schid}"
  puts "------".colorize.green

  parser.chap_list.first(4).map { |x| puts x }
  puts "------".colorize.green

  parser.chap_list.last(4).map { |x| puts x }
  puts "------".colorize.green
rescue err
  puts err.colorize.red
end

tests = [
  # {"ql_la", "7", false},
  # {"ql_la", "9923", false},

  {"jx_la", "7", false},
  # {"jx_la", "7", true},

  # {"69shu", "22729", true},
  {"69shu", "35875", false},
  # {"69shu", "30062", false},

  {"nofff", "18288", false},
  # {"nofff", "18288", true},

  {"rengshu", "181", false},
  # {"rengshu", "181", true},

  {"hetushu", "5", false},
  # {"hetushu", "5", true},

  {"hetushu", "4420", false},
  # {"hetushu", "4420", true},

  {"duokan8", "6293", false},
  # {"duokan8", "6293", true},

  {"xbiquge", "48680", false},
  # {"xbiquge", "48680", true},

  {"paoshu8", "817", false},
  # {"paoshu8", "817", true},

  {"paoshu8", "151780", false},
  # {"paoshu8", "151780", true},

  {"zhwenpg", "aun4tm", false},
  # {"zhwenpg", "aun4tm", true},

  {"5200", "28208", false},
  # {"5200", "28208", true},

  {"bqg_5200", "131878", false},
  {"bqg_5200", "131878", true},

  # {"shubaow", "150092", false},
  # {"shubaow", "150092", true},

  # {"biqubao", "33775", false},
  # {"biqubao", "33775", true},

  # {"bxwxorg", "32154", false},
  # {"bxwxorg", "32154", true},

  {"nofff", "125228", true},
]

tests.each { |sname, snvid, fresh| fetch_info(sname, snvid, fresh: fresh) }
