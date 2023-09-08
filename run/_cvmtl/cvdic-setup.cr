require "sqlite3"

DB.open("sqlite3:var/mtdic/fixed/hints/all_terms.dic") do |db|
  db.exec "drop table if exists terms"

  db.exec <<-SQL
    create table if not exists terms(
      zh varchar primary key,

      hv varchar default '', -- hanviet
      vi varchar default '', -- from chivi users

      bi varchar default '', -- bing result
      qt varchar default '', -- vietphrase quicktran
      en varchar default '', -- english translation

      mtl varchar default '', -- chivi
      lac varchar default '', -- lac postag
      pmt varchar default '', -- pku multiview treebank
      p98 varchar default '', -- pku98 result
      p14 varchar default '', -- people daily 2014
      t3m varchar default '', -- 词典360万（个人整理）
      hlp varchar default '', -- hanlp result
      ud2 varchar default '', -- universal dependency version 2
      ctb varchar default '', -- chinese treebank

      mark integer default 0,
      flag integer default 0
    )
  SQL

  db.exec "pragma journal_mode = WAL"
end

# DB.open("sqlite3:var/dicts/hints/all_terms.mlen.dic") do |db|
#   db.exec <<-SQL
#     create table if not exists msize(

#       fchar varchar primary key,
#       msize integer default 0,
#       utime ingeger default 0
#     )
#   SQL
# end
