module SeedUtil
  extend self

  MAP_SNAME = {
    "!biqugee.com":  "!biqugee",
    "!bxwxorg.com":  "!bxwxorg",
    "!rengshu.com":  "!rengshu",
    "!shubaow.net":  "!shubaow",
    "!duokan8.com":  "!duokan8",
    "!paoshu8.com":  "!paoshu8",
    "!chivi.app":    "!chivi",
    "!xbiquge.bz":   "!xbiquge",
    "!xbiquge.so":   "!xbiquge",
    "!hetushu.com":  "!hetushu",
    "!69shu.com":    "!69shu",
    "!nofff.com":    "!nofff",
    "!5200.tv":      "!5200_tv",
    "!zxcs.me":      "!zxcs_me",
    "!jx.la":        "!jx_la",
    "!ptwxz.com":    "!ptwxz",
    "!uukanshu.com": "!uukanshu",
    "!uuks.org":     "!uuks_org",
    "!bxwx.io":      "!bxwx_io",
    "!133txt.com":   "!133txt",
    "!biqugse.com":  "!biqugse",
    "!bqxs520.com":  "!bqxs520",
    "!yannuozw.com": "!yannuozw",
    "!kanshu8.net":  "!kanshu8",
    "!biqu5200.net": "!biqu5200",
    "!b5200.org":    "!b5200_org",
    "!ibiquge.net":  "!ibiquge",

    "!book.sfacg.com":  "!sfacg",
    "!69shu.io":        "!69shu_io",
    "!zhijianxsw.com":  "!zhijianxsw",
    "!tw.uukanshu.com": "!uukanshu_tw",
    "!69shu.comBK":     "!69shu",
    "!froog.net":       "!froog",
    "!sdyfcm.com":      "!nofff",
    "!sdyfcm":          "!nofff",
    "!5200":            "!5200_tv",
    "!miscs":           "!chivi",
  }

  def fix_sname(sname : String)
    MAP_SNAME.fetch(sname, sname)
  end
end
