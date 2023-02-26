require "../cv_env"
require "clear"

Clear::Log.level = ::Log::Severity::Error if CV_ENV.production?
Clear::SQL.init(CV_ENV.database_url)

PGDB = DB.open(CV_ENV.database_url)
at_exit { PGDB.close }
