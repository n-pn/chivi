require "json"
require "colorize"

require "../../src/_data/remote/rmcata.cr"

def do_test(sname : String, b_id : String | Int32, fresh : Bool = false)
  puts "\n[#{Rmconf.full_cata_link(sname, b_id)}]".colorize.green.bold

  # path = conf.cata_file_path(b_id)
  # Dir.mkdir_p(File.dirname(path))

  parser = Rmcata.new(sname, b_id, stale: fresh ? Time.utc : Time.utc - 10.years)

  puts "update_str: [#{parser.update_str}], real_time: #{Time.unix(parser.update_int)}"
  puts "status_str: [#{parser.status_str}]"
  puts "latest_cid: #{parser.latest_cid}"

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
  {"!69shu", 35875},
  {"!uukanshu", 33933},
  {"!xbiquge", 48680},
  {"!ptwxz", 14836},
  {"!bxwx_gg", 64721},
  {"!yannuozw", "XV1RAgA"},
  {"!133txt", 9},
  {"!jingcaiyuedu", "dl0Zn2"},
  {"!biqu5200", 151081},
  {"!bxwx_net", 153710},
  {"!ddyueshu", 34642769},
  {"!ibiquxs", 268453},
  {"!ishuquge", 5994},
  {"!00kxs", 92948},
  {"!uuks_org", 28834},
  {"!b5200_org", 160872},
  {"!paoshu8", 198663},
  {"!ymxwx", 31577},
  {"!xklxsw", 119080},
  {"!wenku8", 1985},
  {"!paopaoxs", 234492},
  {"!hotupub", 771},
  {"!51shucheng", "guichuideng"},
  {"!tasim", 2777},

  # dead:

  # {"!56shuku_la", 1},
  # {"!5200_tv", 1},
  # {"!biqugee", 1},
  # {"!bxwxorg", 1},
  # {"!duokan8", 1},
  # {"!shubaow", 1},
  # {"!rengshu", 1},
  # {"!nofff", 1},
  # {"!kenshuzw", 1},
  # {"!kanshu8", 1},
  # {"!jx_la", 1},
]

tests.each { |sname, b_id| do_test(sname, b_id) }

# do_test("http://www.kenshuzw.com/xiaoshuo/30192/0/")
# do_test("http://www.ymxwx.com/book/31/31577/index.html")
# do_test("https://www.wenku8.net/novel/1/1973/index.htm")

# do_test("https://www.00kxs.com/html/91/91911/", true)
# do_test("https://www.xklxsw.com/book/119080/", true)
# do_test("https://www.yannuozw.com/yn/VFBUBQ.html")
