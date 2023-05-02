require "pg"
require "colorize"
require "../../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

PG_DB.exec <<-SQL
update vilists set covers = array(
  select bcover from nvinfos
  where bcover <> ''
    and id in (select nvinfo_id from vicrits where vilist_id = vilists.id)
  order by nvinfos.weight desc limit 3
) where book_count > 0
SQL
