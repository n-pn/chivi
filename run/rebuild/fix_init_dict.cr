require "sqlite3"

db = DB.open("sqlite3:var/dicts/init.dic")

db.exec "attach database 'var/mtdic/users/v1_defns.dic' as inp"
db.exec "begin"

db.exec <<-SQL
update terms set _flag = -1
where zstr in ( select key from inp.defns where dic = -1 )
SQL

db.exec <<-SQL
update terms set _flag = 1
where zstr in (
  select key from inp.defns
  where dic = -1 and (ptag = '' or ptag = '-' or ptag = 'i' or ptag = 'l')
)
SQL

db.exec <<-SQL
update terms set _flag = -2
where zstr in ( select key from inp.defns where dic = -2)
SQL

db.exec <<-SQL
update terms set _flag = -3
where zstr in ( select key from inp.defns where dic = -3)
SQL

db.exec <<-SQL
update terms set _flag = -4
where _flag >= 0 and (tags like '%CD%' or tags like '%OD%')
SQL

db.exec "commit"
db.close
