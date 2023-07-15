MAP_BG = {
  "biqugee":  "!biqugee.com",
  "bxwxorg":  "!bxwxorg.com",
  "rengshu":  "!rengshu.com",
  "shubaow":  "!shubaow.net",
  "duokan8":  "!duokan8.com",
  "paoshu8":  "!paoshu8.com",
  "miscs":    "!chivi.app",
  "xbiquge":  "!xbiquge.bz",
  "hetushu":  "!hetushu.com",
  "69shu":    "!69shu.com",
  "sdyfcm":   "!nofff.com",
  "nofff":    "!nofff.com",
  "5200":     "!5200.tv",
  "zxcs_me":  "!zxcs.me",
  "jx_la":    "!jx.la",
  "ptwxz":    "!ptwxz.com",
  "uukanshu": "!uukanshu.com",
  "uuks":     "!uuks.org",
  "bxwxio":   "!bxwx.io",
  "133txt":   "!133txt.com",
  "biqugse":  "!biqugse.com",
  "bqxs520":  "!bqxs520.com",
  "yannuozw": "!yannuozw.com",
  "kanshu8":  "!kanshu8.net",
  "biqu5200": "!biqu5200.net",
  "b5200":    "!b5200.org",
}

# DIR = "var/chaps/infos"
DIR = "var/texts/rgbks"

MAP_BG.each do |key, val|
  inp_dir = "#{DIR}/!#{key}"
  out_dir = "#{DIR}/#{val}"

  if File.exists?(inp_dir) && !File.exists?(out_dir)
    File.rename(inp_dir, out_dir)
    puts "#{inp_dir}=> #{out_dir}"
  end
end
