ENV["CV_ENV"] ||= "production"

require "../../src/_data/_data"

PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
  update rmstems set sname = $1 where sname = $2
SQL

PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
  update rdmemos set sname = $1 where sname = $2
SQL

PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
  update tsrepos set sname = $1 where sname = $2
SQL

PGDB.exec <<-SQL, "!69xinshu.com"
  update rmstems set rlink = replace(rlink, '69shuba', '69xinshu') where sname = $1
SQL
