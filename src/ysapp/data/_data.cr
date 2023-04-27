require "pg"
require "json"

require "../../cv_env"
require "../../_util/hash_util"
require "../../_util/tran_util"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }
