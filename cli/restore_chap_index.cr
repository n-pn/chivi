require "sqlite3"
require "colorize"
require "http/client"

MAP_BG = {
  "!biqugee.com":  "biqugee",
  "!bxwxorg.com":  "bxwxorg",
  "!rengshu.com":  "rengshu",
  "!shubaow.net":  "shubaow",
  "!duokan8.com":  "duokan8",
  "!paoshu8.com":  "paoshu8",
  "!chivi.app":    "miscs",
  "!xbiquge.so":   "xbiquge",
  "!hetushu.com":  "hetushu",
  "!69shu.com":    "69shu",
  "!nofff.com":    "sdyfcm",
  "!5200.tv":      "5200",
  "!zxcs.me":      "zxcs_me",
  "!jx.la":        "jx_la",
  "!ptwxz.com":    "ptwxz",
  "!uukanshu.com": "uukanshu",
  "!uuks.org":     "uuks",
  "!bxwx.io":      "bxwxio",
  "!133txt.com":   "133txt",
  "!biqugse.com":  "biqugse",
  "!bqxs520.com":  "bqxs520",
  "!yannuozw.com": "yannuozw",
  "!kanshu8.net":  "kanshu8",
  "!biqu5200.net": "biqu5200",
  "!b5200.org":    "b5200",
  "_":             "=base",

}

NEW = "var/chaps/texts"
OLD = "/media/nipin/Vault/Asset/chivi_db/chtexts"

DB.open("sqlite3:var/chaps/seed-infos.db") do |db|
  db.query_each "select sname, s_bid from seeds" do |rs|
    sname, s_bid = rs.read(String, Int32)
    sname = MAP_BG[sname]? || sname

    fpath = "#{sname}/#{s_bid}/index.db"

    new_path = "#{NEW}/#{fpath}"
    db2_path = "var/chaps/seeds/#{sname}/#{s_bid}.db2"

    next if File.file?(new_path) || File.file?(db2_path)

    Dir.mkdir_p(File.dirname(new_path))

    next unless File.file? "#{NEW}/#{sname}/#{s_bid}/index.r2"

    puts "trying download from r2: #{new_path}"

    HTTP::Client.get("https://cr2.chivi.app/texts/#{fpath}") do |res|
      next unless res.success?
      File.write(new_path, res.body_io)
      puts "#{new_path} downloaded from cloudflare r2"
    end
  end
end
