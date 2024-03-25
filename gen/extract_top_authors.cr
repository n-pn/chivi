require "sqlite3"

ENV["CV_ENV"] = "production"
require "../src/_data/_data"

require "../src/_util/book_util"

tu_authors = DB.open("sqlite3:var/zroot/tubooks.db3") do |db|
  db.query_all <<-SQL, as: String
    select distinct(author) from tubooks where voters > 1;
  SQL
end

puts "tu authors: #{tu_authors.size}"

File.write("/2tb/working/authors/tu-2votes.txt", tu_authors.join('\n'))

ys_authors = PGDB.query_all <<-SQL, as: String
  select distinct(author) from ysbooks where voters > 1;
SQL

puts "ys authors: #{ys_authors.size}"

File.write("/2tb/working/authors/ys-2votes.txt", ys_authors.join('\n'))

up_authors = PGDB.query_all <<-SQL, as: String
  select distinct(au_zh) from upstems;
SQL

puts "up authors: #{up_authors.size}"

File.write("/2tb/working/authors/upstems.txt", up_authors.join('\n'))

rm_authors = PGDB.query_all <<-SQL, as: String
  select distinct(author_zh) from rmstems
  where sname in ('!rengshu.com', '!zxcs.me', '!hetushu.com')
SQL

puts "rm authors: #{rm_authors.size}"

File.write("/2tb/working/authors/rmstems.txt", rm_authors.join('\n'))

wn_authors = PGDB.query_all <<-SQL, as: String
  select distinct(author_zh) from wninfos
  where id in (
    select wn_id from tsrepos
    where tsrepos.id in (select rd_id from rdmemos)
  )
SQL

puts "wn authors: #{wn_authors.size}"

File.write("/2tb/working/authors/library.txt", wn_authors.join('\n'))

uc_authors = PGDB.query_all <<-SQL, as: String
  select distinct(author_zh) from wninfos
  where id in (select nvinfo_id from vicrits)
SQL

puts "uc authors: #{uc_authors.size}"

File.write("/2tb/working/authors/vicrits.txt", uc_authors.join('\n'))

zh_authors = File.read_lines("/2tb/var.chivi/_conf/rating_fix.tsv", chomp: true).map do |line|
  line.split('\t')[1]
end

puts "zh authors: #{zh_authors.size}"

File.write("/2tb/working/authors/zhwenpg.txt", zh_authors.join('\n'))

files = Dir.glob("/2tb/working/authors/*.txt")
authors = files.flat_map { |file| File.read_lines(file) }.uniq!
fixed_authors = authors.map { |author| BookUtil.fix_author(author) }

puts "authors: #{fixed_authors.size}"
File.write("/2tb/working/authors.txt", fixed_authors.join('\n'))
