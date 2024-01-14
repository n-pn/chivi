ENV["CV_ENV"] ||= "production"

require "../../src/_data/_data"

# PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
#   update rmstems set sname = $1 where sname = $2
# SQL

# PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
#   update rdmemos set sname = $1 where sname = $2
# SQL

# PGDB.exec <<-SQL, "!69xinshu.com"
#   update rmstems set rlink = replace(rlink, '69shuba', '69xinshu') where sname = $1
# SQL

# PGDB.exec <<-SQL, "!69xinshu.com", "!69shuba.com"
#   update tsrepos set sname = $1 where sname = $2
# SQL

# PGDB.exec <<-SQL
#   update tsrepos set rm_slink = replace(rm_slink, '69shuba', '69xinshu')
#   where rm_slink like 'https://www.69shuba.com%'
# SQL

PGDB.exec <<-SQL
  update tsrepos set rm_slink = replace(rm_slink, 'piaotian', 'piaotia')
  where rm_slink like 'https://www.piaotian.com%'
SQL
