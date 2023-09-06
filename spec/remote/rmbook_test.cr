require "json"
require "../../src/zroot/raw_html/raw_rmbook.cr"

def fetch_info(sname : String, s_bid : String | Int32, fresh = false) : Nil
  puts "\n[#{Rmconf.full_book_link(sname, s_bid)}]".colorize.green.bold
  parser = RawRmbook.init(sname, s_bid, stale: Time.utc - (fresh ? 10.seconds : 10.years))

  puts "------".colorize.green

  output = {
    btitle: parser.btitle,
    author: parser.author,

    status: parser.status_str,
    update: parser.update_str,
    latest: parser.latest_cid,

    cover: parser.cover,
    intro: parser.intro,
    genre: parser.genre,
    xtags: parser.xtags,
  }

  puts output.to_pretty_json
rescue err
  puts err.inspect_with_backtrace
end

tests = [
  {"!hetushu", 5, false},
  # {"!jx_la", "7", false},
  {"!69shu", 35875, false},
  # {"!rengshu", 181, false},
  # {"!duokan8", 6293, false},
  {"!xbiquge", 48680, false},
  {"!paoshu8", 817, false},
  # {"!5200_tv", 28208, false},
  # {"!shubaow", 150092, false},
  # {"!biqugee", 33775, false},
  # {"!bxwxorg", 32154, false},
  # {"!nofff", "10", false},
  {"!uukanshu", 33933, false},

  # {"!biqugse", 69761, false},
  # {"!bqxs520", 122958, false},

  {"!b5200_org", 160872, false},
  # {"!bxwx_gg", 127400, false},

  # {"!yannuozw", 147108, false},

  # {"!kanshu8", 59127, false},

  {"!133txt", 9, false},

  {"!hotupub", 100, false},
  {"!ymxwx", 100, false},
  {"!wenku8", 1000, false},
  {"!uuks_org", 28834, false},
  {"!biqu5200", 1049, false},

  {"!ishuquge", 1000, false},
  {"!ptwxz", 15261, false},

  {"!tasim", 2777, false},
  {"!zsdade", 3804, false},
  {"!os2022", 8185, false},
  {"!madcowww", 145546, false},
  {"!egyguard", 148776, false},
]

tests.each do |sname, s_bid, fresh|
  fetch_info(sname, s_bid, fresh: fresh)
end
