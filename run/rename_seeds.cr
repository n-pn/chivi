require "../src/_data/_data"

NFO_DIR = "/app/chivi.dev/var/chaps/infos"
TXT_DIR = "/app/chivi.dev/var/texts/rgbks"
ZIP_DIR = "/app/chivi.dev/var/texts/rzips"

def rename_seed(old_sname : String, new_sname : String)
  # PGDB.exec "begin transaction"
  # PGDB.exec "update wnseeds set sname = $1 where sname = $2", new_sname, old_sname
  # PGDB.exec "update ubmemos set lr_sname = $1 where lr_sname = $2", new_sname, old_sname
  # PGDB.exec "commit"

  File.rename("#{NFO_DIR}/#{old_sname}", "#{NFO_DIR}/#{new_sname}") rescue puts "renamed"
  File.rename("#{TXT_DIR}/#{old_sname}", "#{TXT_DIR}/#{new_sname}") rescue puts "renamed"
  File.rename("#{ZIP_DIR}/#{old_sname}", "#{ZIP_DIR}/#{new_sname}") rescue puts "renamed"
end

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
}

MAP_SNAME.each do |old_sname, new_sname|
  rename_seed(old_sname.to_s, new_sname)
  puts "updated: #{old_sname} => #{new_sname}"
end

rename_seed("_", "~draft")
