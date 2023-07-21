require "json"
require "../../src/tasks/remote/shared/rmcata.cr"
require "../../src/tasks/remote/shared/rmseed.cr"

def do_test(sname : String, bid : String | Int32)
  conf = Rmconf.load_known!(sname)

  cata_path = conf.make_cata_path(bid)
  cata_link = conf.make_full_link(cata_path)

  save_to = conf.cata_file_path(bid)
  too_old = Time.utc - 10.years

  html = Rmseed.new(conf).read_page(cata_path, save_to, too_old: too_old)
  parser = Rmcata.new(conf, html)

  puts "\n[#{cata_link}]".colorize.green.bold
  puts "------".colorize.green

  # puts "latest_cid: #{parser.latest_cid}"
  # puts "update_str: #{parser.update_str}"

  chlist = parser.chap_list
  puts "chap_count: #{chlist.size}"
  puts "------".colorize.green

  chlist.first(4).map { |x| puts [x.ch_no, x.s_cid, x.ctitle, x.subdiv] }
  puts "------".colorize.green

  chlist.last(4).map { |x| puts [x.ch_no, x.s_cid, x.ctitle, x.subdiv] }
  puts "------".colorize.green
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

tests = [
  {"!69shu", 35875},
  {"!hetushu", 5},

  # {"!xbiquge", 48680},
  # {"!paoshu8", 817},
  # {"!biqu5200", 131878},

  # {"!uukanshu", 33933},

  # {"!b5200", 160872},
  # {"!bxwxio", 127400},

  # {"!133txt", 9},

  # {"!uuks", 56862},

  {"!69shu", 41121},
]

tests.each { |sname, bid| do_test(sname, bid) }

# do_test("http://www.kenshuzw.com/xiaoshuo/30192/0/")
# do_test("http://www.ymxwx.com/book/31/31577/index.html")
# do_test("https://www.wenku8.net/novel/1/1973/index.htm")

# do_test("https://www.00kxs.com/html/91/91911/", true)
# do_test("https://www.xklxsw.com/book/119080/", true)
# do_test("https://www.yannuozw.com/yn/VFBUBQ.html")
