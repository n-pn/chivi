enum WN::SeedType
  Chivi
  Draft
  Users
  Globs
  Other

  def read_privi(is_owner = false, base_privi = 2)
    case self
    when Draft then 1
    when Chivi then 2
    when Users then is_owner ? 1 : base_privi
    else            3
    end
  end

  def edit_privi(is_owner = false)
    case self
    when Draft then 1
    when Chivi then 3
    when Users then is_owner ? 2 : 4
    else            3
    end
  end

  def delete_privi(is_owner = false)
    case self
    when Globs then 3
    when Users then is_owner ? 2 : 4
    else            5
    end
  end

  def type_name
    case self
    when Chivi then "chính thức"
    when Draft then "tạm thời"
    when Users then "cá nhân"
    when Globs then "bên ngoài"
    else            "đặc biệt"
    end
  end

  def self.parse(sname : String)
    fchar = sname[0]
    case
    when fchar == '!'      then Globs
    when fchar == '@'      then Users
    when sname == "~chivi" then Chivi
    when sname == "~draft" then Draft
    else                        Other
    end
  end

  def self.read_privi(sname : String, uname : String, base_privi : Int32)
    parse(sname).read_privi(owner?(sname, uname), base_privi)
  end

  def self.edit_privi(sname : String, uname : String)
    parse(sname).edit_privi(owner?(sname, uname))
  end

  def self.delete_privi(sname : String, uname : String)
    parse(sname).delete_privi(owner?(sname, uname))
  end

  def self.owner?(sname : String, uname : String)
    sname == "@#{uname}"
  end
end

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
  }

  def fix_sname(sname : String)
    MAP_SNAME.fetch(sname, sname)
  end
end
