# require "../src/wnapp/data/wn_seed"
# require "../src/_data/wnovel/wnseed"

# struct Input
#   include DB::Serializable
#   include DB::Serializable::NonStrict

#   getter wn_id : Int32 = 0
#   getter sname : String = ""

#   getter s_bid : Int32 = 0
#   getter mtime : Int64 = 0

#   getter chap_total : Int32 = 0
#   getter chap_avail : Int32 = 0

#   getter rm_links : String = "[]" # remote page link
#   getter rm_stime : Int64 = 0     # remote sync time

#   getter read_privi : Int32 = 0

#   getter _flag : Int32 = 0
# end

# STMT = "select * from seeds order by wn_id asc, sname asc"
# db_path = "sqlite3:/2tb/app.chivi/var/zchap/seed-infos.db"
# inputs = DB.open(db_path, &.query_all(STMT, as: Input))

# PGDB.exec "begin transaction"

# MAP_SNAME = {
#   "!biqugee.com":  "!biqugee",
#   "!bxwxorg.com":  "!bxwxorg",
#   "!rengshu.com":  "!rengshu",
#   "!shubaow.net":  "!shubaow",
#   "!duokan8.com":  "!duokan8",
#   "!paoshu8.com":  "!paoshu8",
#   "!chivi.app":    "!chivi",
#   "!xbiquge.bz":   "!xbiquge",
#   "!xbiquge.so":   "!xbiquge",
#   "!hetushu.com":  "!hetushu",
#   "!69shu.com":    "!69shu",
#   "!nofff.com":    "!nofff",
#   "!5200.tv":      "!5200_tv",
#   "!zxcs.me":      "!zxcs_me",
#   "!jx.la":        "!jx_la",
#   "!ptwxz.com":    "!ptwxz",
#   "!uukanshu.com": "!uukanshu",
#   "!uuks.org":     "!uuks_org",
#   "!bxwx.io":      "!bxwx_io",
#   "!133txt.com":   "!133txt",
#   "!biqugse.com":  "!biqugse",
#   "!bqxs520.com":  "!bqxs520",
#   "!yannuozw.com": "!yannuozw",
#   "!kanshu8.net":  "!kanshu8",
#   "!biqu5200.net": "!biqu5200",
#   "!b5200.org":    "!b5200_org",
#   "!ibiquge.net":  "!ibiquge",

#   "!book.sfacg.com":  "!sfacg",
#   "!69shu.io":        "!69shu_io",
#   "!zhijianxsw.com":  "!zhijianxsw",
#   "!tw.uukanshu.com": "!uukanshu_tw",
#   "!69shu.comBK":     "!69shu",
#   "!froog.net":       "!froog",
#   "_":                "~draft",
# }

# def map_sname(sname : String)
#   return sname if sname[0] == '@'
#   MAP_SNAME[sname]
# end

# inputs.each do |input|
#   next if input.wn_id < 0

#   output = WN::Wnstem.load(wn_id: input.wn_id, sname: map_sname(input.sname))
#   next if output.chap_total >= input.chap_total

#   output.s_bid = input.s_bid

#   output.chap_total = input.chap_total
#   output.chap_avail = input.chap_avail

#   output.mtime = input.mtime

#   output.rlink = Array(String).from_json(input.rm_links).first? || ""
#   output.rtime = input.rm_stime

#   output.privi = input.read_privi.to_i16
#   output._flag = input._flag.to_i16

#   output.upsert!

#   puts "#{input.wn_id}/#{input.sname} (#{input.chap_total}) synced"
# rescue ex
#   puts [input.wn_id, input.sname, ex.message.colorize.red]
# end

# PGDB.exec "commit"
