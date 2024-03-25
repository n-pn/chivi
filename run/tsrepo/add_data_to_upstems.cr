ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"

PGDB.exec <<-SQL
  update upstems set au_zh = (select author_zh from wninfos where wninfos.id = upstems.wn_id  limit 1)
  where wn_id is not null and wn_id > 0
SQL

PGDB.exec <<-SQL
  update upstems set au_vi = (select author_vi from wninfos where wninfos.id = upstems.wn_id  limit 1)
  where wn_id is not null and wn_id > 0
SQL

PGDB.exec <<-SQL
  update upstems set zdesc = (select zintro from wninfos where wninfos.id = upstems.wn_id limit 1)
  where wn_id is not null and wn_id > 0
SQL

PGDB.exec <<-SQL
  update upstems set img_og = (select scover from wninfos where wninfos.id = upstems.wn_id  limit 1)
  where wn_id is not null and wn_id > 0 and img_og = ''
SQL

PGDB.exec <<-SQL
  update upstems set img_cv = '//img.chivi.app/covers/' || (select bcover from wninfos where wninfos.id = upstems.wn_id limit 1)
  where wn_id is not null and wn_id > 0
SQL
