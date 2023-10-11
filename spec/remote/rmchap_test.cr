require "colorize"

require "../../src/rdapp/_raw/raw_rmchap.cr"

def do_test(sname : String, s_bid : Int32 | String, s_cid : Int32 | String, reset = false)
  full_link = Rmhost.chap_url(sname, s_bid, s_cid)
  puts "\n[#{full_link.colorize.blue.bold}]"
  puts

  stale = Time.utc - (reset ? 3.minutes : 10.years)
  parser = RawRmchap.from_seed(sname, s_bid, s_cid, stale)
  parser.parse_page!

  puts parser.title.colorize.green
  puts "---".colorize.dark_gray
  puts parser.paras.first(4).join('\n')
  puts "---".colorize.dark_gray
  puts parser.paras.last(4).join('\n')
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

# do_test("!hetushu", 1640, 1099716, reset: false)
# do_test("!uukanshu", 514, 4531, reset: false)

# do_test("!69shu", 30494, 22578503, reset: false)
# do_test("!ptwxz", 1806, 803058, reset: false)

# # do_test("!rengshu", 4243, 1408503, reset: false)

# do_test("!b5200_org", 160872, 183484031, reset: false)
# do_test("!bxwx_gg", 127400, 52941263, reset: false)

# do_test("!xbiquge", 42736, 26039221, reset: false)

# # do_test("!duokan8", 1986, 400011, reset: false)

# do_test("!paoshu8", 1986, 1447835, reset: false)

# do_test("!biqu5200", 139731, 174666986, reset: false)
# do_test("!tasim", 2777, 1, reset: false)
do_test("!piaotian.com", 15296, 10909391, reset: false)

# do_test("!shubaow", 150092, 32706021, reset: false)
# do_test("!biqugee", 33775, 18804401, reset: false)

# do_test("!bxwxorg", 119227, 1367374, reset: false)
# do_test("!biqugee", 51452, 649594, reset: false)

# do_test("!133txt", 9, 5900, reset: false)
# do_test("!5200_tv", 28208, 12163631, reset: false)
# do_test("!biqugse", 69761, 95223327, reset: false)
# do_test("!bqxs520", 122958, 95416098, reset: false)

# do_test("!uuks_org", 23389, 292361, reset: false)
# do_test("!yannuozw", 147108, 69474701, reset: false)

# do_test("!kanshu8", 59127, 47845259, reset: false)
