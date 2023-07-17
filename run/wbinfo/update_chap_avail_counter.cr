require "sqlite3"

SRC = "/2tb/var.chivi/zbook"
TXT = "var/texts/rgbks"

def update_chap_avail(sname : String)
  db_path = "#{SRC}/#{sname}.db"

  DB.open("sqlite3:#{db_path}") do |db|
    Dir.glob("#{TXT}/!#{sname}/*/").each do |dir_path|
      chap_avail = Dir.children(dir_path).select!(&.ends_with?(".gbk")).size

      puts "- #{dir_path} has #{chap_avail} chapters"

      next if chap_avail == 0
      db.exec "update books set chap_avail = $1 where id = $2", chap_avail, File.basename(dir_path).to_i
    end
  end
end

# update_chap_avail "hetushu.com"
update_chap_avail "zxcs.me"
