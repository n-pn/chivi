require "pg"
require "colorize"
require "../../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

PG_DB.exec <<-SQL
update yslists set covers = array(
  select bcover::text from wninfos where bcover <> '' and id in (select nvinfo_id from yscrits where yslist_id = yslists.id)
  order by wninfos.weight desc limit 3
) where book_count > 0
SQL
