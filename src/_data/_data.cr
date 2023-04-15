require "pg"
require "../cv_env"

PGDB = DB.open(CV_ENV.database_url)
at_exit { PGDB.close }

struct PQ::Param
  def self.encode(val : Symbol)
    slice = val.to_s.to_slice
    new slice, slice.size, 1_i16
  end
end
