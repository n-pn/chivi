require "compress/zip"
require "clear"

require "../../cv_env"
require "../../_util/hash_util"
require "../../_util/tran_util"

Clear::Log.level = ::Log::Severity::Error if CV_ENV.production?
Clear::SQL.init(CV_ENV.database_url)

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }
