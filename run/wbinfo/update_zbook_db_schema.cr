require "sqlite3"

SRC = "/2tb/var.chivi/zbook"

# Dir.glob("#{SRC}/*.db").each do |db_path|
#   DB.open("sqlite3:#{db_path}") do |db|
#     # db.exec "alter table books rename column status_str to pub_status"
#     # db.exec "alter table books rename column update_str to updated_at"
#     # db.exec "alter table books rename column rtime to _utime"
#     # db.exec "alter table books rename column _flag to _grade"

#     db.exec "alter table books add column chap_avail int not null default 0"
#   end
# end

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
