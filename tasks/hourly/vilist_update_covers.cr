ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"

PGDB.exec <<-SQL
update vilists set covers = array(
  select bcover from wninfos
  where bcover <> ''
    and id in (select nvinfo_id from vicrits where vilist_id = vilists.id)
  order by wninfos.weight desc limit 3
) where book_count > 0
SQL
