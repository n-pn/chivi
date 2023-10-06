require "pg"

ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

def update(old_sname : String, new_sname : String)
  File.rename("var/stems/rm#{old_sname}", "var/stems/rm#{new_sname}") rescue nil
  File.rename("var/texts/rm#{old_sname}", "var/texts/rm#{new_sname}") rescue nil

  PGDB.exec "update rmstems set sname = $1 where sname = $2", new_sname, old_sname
  PGDB.exec "update wnseeds set sname = $1 where sname = $2", new_sname, old_sname
  puts "#{old_sname} => #{new_sname}"
end

# update("!ptwxz", "!piaotian.com")
# update("!jx_la", "!jx.la")
# update("!zsdade", "!zsdade.com")

# update("!shubaow", "!shubaow.net")
# update("!rengshu", "!rengshu.com")

# update("!133txt", "!133txt.com")
# update("!uukanshu", "!uukanshu.com")
# update("!nofff", "!nofff.com")
# update("!biqugee", "!biqugee.com")
# update("!bxwxorg", "!bxwxorg.com")
# update("!paoshu8", "!paoshu8.com")
# update("!xbiquge", "!xbiquge.bz")
# update("!hetushu", "!hetushu.com")
# update("!5200_tv", "!biquluo.cc")
# update("!uuks_org", "!m.uuks.org")
# update("!zxcs_me", "!zxcs.me")
# update("!biqu5200", "!biqu5200.net")

# update("!b5200_org", "!b5200.org")

# update("!os2022", "!os2022.com")
# update("!madcowww", "!madcowww.com")
# update("!egyguard", "!egyguard.com")

# update("!00kxs", "!00kxs.com")
# update("!51shucheng", "!51shucheng.net")
# update("!56shuku", "!56shuku.la")
# update("!biqugse", "!biqugse.com")
# update("!bxwx_gg", "!bxwx.gg")
# update("!bxwx_net", "!bxwx.net")
# update("!ddyueshu", "!ddyueshu.com")
# update("!duokan8", "!duokanba.com")
# update("!hotupub", "!hotupub.net")
# update("!ibiquxs", "!ibiquxs.info")
# update("!bqxs520", "!bqxs520.com")
# update("!jingcaiyuedu", "!jingcaiyuedu6.com")
# update("!ishuquge", "!ishuquge.org")
# update("!uukanshu_tw", "!tw.uukanshu.com")
# update("!kanshu8", "!kanshu8.la")
# update("!paopaoxs", "!paopaoxs.cn")
# update("!wenku8", "!wenku8.net")
# update("!kenshuzw", "!kenshuzw.com")
# update("!ymxwx", "!ymoxuan.net")
# update("!yannuozw", "!yannuozw.com")
# update("!xklxsw", "!m.xklxsw.net")
