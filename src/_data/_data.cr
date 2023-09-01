require "pg"
require "crorm"
require "../cv_env"

PGDB = DB.open(CV_ENV.database_url)
at_exit { PGDB.close }

struct PQ::Param
  def self.encode(val : Symbol)
    encode %{"#{val}"}.to_slice
  end
end
