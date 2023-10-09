module RD::Rmrank
  SNAMES = {
    "!69shuba.com",
    "!piaotian.com",
    "!133txt.com",
    "!tasim.net",
    "!zsdade.com",
    "!uukanshu.com",
    "!tw.uukanshu.com",
    "!biqu5200.net",
    "!biquluo.cc",
    "!bxwx.net",
    "!ishuquge.org",
    "!os2022.com",
    "!ymoxuan.net",
    "!egyguard.com",
    "!madcowww.com",
    "!xbiquge.bz",
    "!jx.la",
    "!bxwxorg.com",
    "!biqugee.com",
    "!rengshu.com",
    "!paoshu8.com",
    "!duokanba.com",
    "!shubaow.net",
    "!nofff.com",
  }

  def self.index(sname : String)
    SNAMES.index(sname) || 15
  end
end
