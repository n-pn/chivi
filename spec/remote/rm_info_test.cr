require "json"
require "../../src/_init/remote_info.cr"

def fetch_info(sname, snvid, fresh = false) : Void
  puts "\n[#{CV::SiteLink.info_url(sname, snvid)}]".colorize.green.bold
  parser = CV::RemoteInfo.new(sname, snvid, ttl: fresh ? 10.seconds : 10.years)

  puts "------".colorize.green

  output = {
    btitle: parser.btitle,
    author: parser.author,
    genres: parser.genres.join("\t"),
    bintro: parser.bintro,
    bcover: parser.bcover,
    status: parser.status_str,
    update: parser.update_str,
  }

  puts output.to_pretty_json

  puts "------".colorize.green

  puts "chap_count: #{parser.chap_infos.size}"
  puts "last_schid: #{parser.last_schid}"
  puts "------".colorize.green

  parser.chap_infos.first(4).map { |x| puts x }
  puts "------".colorize.green

  parser.chap_infos.last(4).map { |x| puts x }
  puts "------".colorize.green
rescue err
  puts err.colorize.red
end

tests = [
  # {"ql_la", "7", false},
  # {"ql_la", "9923", false},

  # {"jx_la", "7", false},
  # {"jx_la", "7", true},

  # {"69shu", "22729", true},
  {"69shu", "35875", false},
  # {"69shu", "30062", false},

  {"rengshu", "181", false},
  # {"rengshu", "181", true},

  {"hetushu", "5", false},
  # {"hetushu", "5", true},

  # {"hetushu", "4420", false},
  # {"hetushu", "4420", true},

  {"duokan8", "6293", false},
  # {"duokan8", "6293", true},

  {"xbiquge", "48680", false},
  # {"xbiquge", "48680", true},

  {"paoshu8", "817", false},
  # {"paoshu8", "817", true},

  {"paoshu8", "151780", false},
  # {"paoshu8", "151780", true},

  # {"zhwenpg", "aun4tm", false},
  # {"zhwenpg", "aun4tm", true},

  {"5200", "28208", false},
  # {"5200", "28208", true},

  {"biqu5200", "131878", false},
  # {"biqu5200", "131878", true},

  {"shubaow", "150092", false},
  # {"shubaow", "150092", true},

  {"biqugee", "33775", false},
  # {"biqugee", "33775", true},

  {"bxwxorg", "32154", false},
  # {"bxwxorg", "32154", true},

  # {"sdyfcm", "10", false},
  # {"sdyfcm", "125228", true},

  {"ptwxz", "1806", false},
  # {"ptwxz", "1806", true},

  {"biquyue", "56580", false},
  # {"biquyue", "56580", true},

  {"xswang", "2028", false},
  # {"xswang", "2028", true},
]

tests.each do |sname, snvid, fresh|
  fetch_info(sname, snvid, fresh: fresh)
end
