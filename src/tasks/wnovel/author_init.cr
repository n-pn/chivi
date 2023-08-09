require "../../_data/_data"
require "../../zroot/author"
require "../../zroot/ysbook"
require "../../zroot/tubook"
require "../../zroot/rmbook"

OUT_DB = ZR::Author.db

entries = {} of String => ZR::Author
scoring = Hash(String, Int32).new(0)

ZR::Author.all(OUT_DB).each do |author|
  entries[author.name_zh] = author
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  total = 0
  stmt = "select id, zname, vname from authors where id >= $1 and id <= $2"

  PGDB.query_each stmt, lower, upper do |rs|
    total += 1
    wa_id, zname, vname = rs.read(Int32, String, String)

    entry = entries[zname] ||= ZR::Author.load(zname)

    entry.name_vi = vname
    entry.wa_id = wa_id
  end

  puts "- <authors> block: #{block}, books: #{total}"
  break if total == 0
end

####

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999
  total = 0

  stmt = "select author, btitle, voters from ysbooks where id >= $1 and id <= $2"
  ZR::Ysbook.open_db do |db|
    db.query_each stmt, lower, upper do |rs|
      total += 1

      author, btitle, voters = rs.read(String, String, Int32)
      author, _ = BookUtil.fix_names(author, btitle)

      entries[author] ||= ZR::Author.load(author, db: OUT_DB)
      scoring[author] = {scoring[author], voters}.max
    end
  end

  puts "- <ysbooks> block: #{block}, books: #{total}"
  break if total == 0
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  stmt = "select author, btitle, voters from tubooks where id >= $1 and id <= $2"
  total = 0

  ZR::Tubook.open_db do |db|
    db.query_each stmt, lower, upper do |rs|
      total += 1

      author, btitle, voters = rs.read(String, String, Int32)
      author, _ = BookUtil.fix_names(author, btitle)

      entries[author] ||= ZR::Author.load(author, db: OUT_DB)
      scoring[author] = {scoring[author], voters}.max
    end
  end

  puts "- <tubooks> block: #{block}, books: #{total}"
  break if total == 0
end

####

TRUSTED_SEEDS = {
  "!hetushu",
  "!69shu",
  "!xbiquge",
  "!uukanshu",
  # "!shubaow",
  "!ptwxz",
  # "!zxcs_me",
  # "!rengshu",
  "!wenku8",
}

TRUSTED_SEEDS.each do |sname|
  db_path = ZR::Rmbook.db_path(sname)
  puts "- load from: #{db_path}"
  stmt = "select author, btitle from rmbooks"

  DB.open("sqlite3:#{db_path}?mode=ro") do |db|
    db.query_each stmt do |rs|
      author, btitle = rs.read(String, String)
      author, _ = BookUtil.fix_names(author, btitle)
      entries[author] ||= ZR::Author.load(author, db: OUT_DB)
    end
  end
end

####

def map_flag(scoring : Int32)
  case scoring
  when .> 810 then 5
  when .> 270 then 4
  when .> 90  then 3
  when .> 30  then 2
  when .> 10  then 1
  else             0
  end
end

flags = [0, 0, 0, 0, 0, 0]

scoring.each do |author, value|
  entry = entries[author]
  entry._flag = {entry._flag, map_flag(value)}.max
  flags[entry._flag] += 1
end

puts "- assigned flags: #{flags}"

OUT_DB.exec "begin"
entries.each_value(&.upsert!(db: OUT_DB))
OUT_DB.exec "commit"

puts "- saved entries: #{entries.size}"

# puts OUT_DB.query_one("select count(*) from authors", as: Int32)
