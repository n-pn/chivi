require "../../_data/_data"
require "../../zroot/author"
require "../../zroot/btitle"
require "../../zroot/ysbook"
require "../../zroot/tubook"
require "../../zroot/rmbook"

author_flag = Hash(String, Int32).new(0)
btitle_flag = Hash(String, Int32).new(0)

ZR::Author.open_db do |db|
  stmt = "select name_zh, _flag from authors where _flag > 0"
  db.query_each(stmt) do |rs|
    zname, _flag = rs.read(String, Int32)
    author_flag[zname] = _flag
  end
end

entries = {} of String => ZR::Btitle

ZR::Btitle.all(OUT_DB).each do |btitle|
  entries[btitle.name_zh] = btitle
end

OUT_DB = ZR::Btitle.db

# record Btitle, id : Int32, zname : String, vname : String, hname : String do
#   include DB::Serializable
# end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999
  total = 0
  lower = 5 if lower < 5

  stmt = "select btitle_zh, btitle_vi from wninfos where id >= $1 and id <= $2"

  PGDB.query_each stmt, lower, upper do |rs|
    total += 1
    zname, vname = rs.read(String, String)

    entry = entries[zname] ||= ZR::Btitle.load(zname)
    entry.name_mt = vname unless vname == zname || vname.empty?
  end

  puts "- block: #{block}, books: #{total}"
  break if total == 0
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999
  total = 0

  stmt = "select author, btitle from ysbooks where id >= $1 and id <= $2"

  ZR::Ysbook.open_db do |db|
    db.query_each stmt, lower, upper do |rs|
      total += 1

      author, btitle = rs.read(String, String)
      author, btitle = BookUtil.fix_names(author, btitle)

      entries[btitle] ||= ZR::Btitle.load(btitle, db: OUT_DB)
      btitle_flag[btitle] = {btitle_flag[btitle], author_flag[author]}.max
    end
  end

  puts "- block: #{block}, books: #{total}"
  break if total == 0
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999
  total = 0

  stmt = "select author, btitle from tubooks where id >= $1 and id <= $2"

  ZR::Tubook.open_db do |db|
    db.query_each stmt, lower, upper do |rs|
      total += 1

      author, btitle = rs.read(String, String)
      author, btitle = BookUtil.fix_names(author, btitle)

      entries[btitle] ||= ZR::Btitle.load(btitle, db: OUT_DB)
      btitle_flag[btitle] = {btitle_flag[btitle], author_flag[author]}.max
    end
  end

  puts "- block: #{block}, books: #{total}"
  break if total == 0
end

####

TRUSTED_SEEDS = {
  "!hetushu",
  "!69shu",
  "!xbiquge",
  "!uukanshu",
  "!shubaow",
  "!ptwxz",
  "!zxcs_me",
  "!rengshu",
  "!wenku8",
}

TRUSTED_SEEDS.each do |sname|
  db_path = ZR::Rmbook.db_path(sname)
  puts "- load from: #{db_path}"
  stmt = "select author, btitle from rmbooks"

  DB.open("sqlite3:#{db_path}?mode=ro") do |db|
    db.query_each stmt do |rs|
      author, btitle = rs.read(String, String)
      author, btitle = BookUtil.fix_names(author, btitle)
      entries[btitle] ||= ZR::Btitle.load(btitle, db: OUT_DB)
    end
  end
end

flags = [0, 0, 0, 0, 0, 0]

btitle_flag.each do |btitle, _flag|
  flags[_flag] += 1
  entries[btitle]._flag = _flag
end

puts "- assigned flags: #{flags}"

OUT_DB.exec "begin"
entries.each_value(&.upsert!(db: OUT_DB))
OUT_DB.exec "commit"

puts "- saved entries: #{entries.size}"
