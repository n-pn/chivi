require "json"
require "colorize"

require "../../src/_data/remote/rmcata.cr"
require "../../src/_data/remote/rmseed.cr"

def do_test(sname : String, bid : String | Int32)
  conf = Rmconf.load_known!(sname)

  cata_path = conf.make_cata_path(bid)
  cata_link = conf.make_full_link(cata_path)

  puts "\n[#{cata_link}]".colorize.green.bold

  save_to = conf.cata_file_path(bid)
  too_old = Time.utc - 10.years

  Dir.mkdir_p(File.dirname(save_to))
  html = Rmseed.new(conf).read_page(cata_path, save_to, too_old: too_old)

  parser = Rmcata.new(html, conf, bid)

  puts "latest_cid: #{parser.latest_cid}"
  puts "update_str: #{parser.update_str}"

  chlist = parser.chap_list
  puts "chap_count: #{chlist.size}"
  puts "------".colorize.green

  chlist.first(4).map { |x| puts [x.ch_no, x.s_cid, x.cpath, x.ctitle, x.subdiv] }
  puts "------".colorize.green

  chlist.last(4).map { |x| puts [x.ch_no, x.s_cid, x.cpath, x.ctitle, x.subdiv] }
  puts "------".colorize.green
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

tests = [
  {"!hetushu", 5},
  # {"!69shu", 35875},
  # {"!uukanshu", 33933},
  # {"!xbiquge", 48680},
  # {"!ptwxz", 14836},
  # {"!bxwx_gg", 64721},
  # {"!yannuozw", "XV1RAgA"},
  # {"!133txt", 9},
  # {"!jingcaiyuedu", "dl0Zn2"},
  # {"!biqu5200", 151081},
  # {"!bxwx_net", 153710},
  # {"!ddyueshu", 34642769},
  # {"!ibiquxs", 268453},
  # {"!ishuquge", 5994},

  # {"!00kxs", 92948},
  # {"!uuks_org", 28834},
  # {"!b5200_org", 160872},

  # {"!paoshu8", 817},
]

tests.each { |sname, bid| do_test(sname, bid) }

# do_test("http://www.kenshuzw.com/xiaoshuo/30192/0/")
# do_test("http://www.ymxwx.com/book/31/31577/index.html")
# do_test("https://www.wenku8.net/novel/1/1973/index.htm")

# do_test("https://www.00kxs.com/html/91/91911/", true)
# do_test("https://www.xklxsw.com/book/119080/", true)
# do_test("https://www.yannuozw.com/yn/VFBUBQ.html")
