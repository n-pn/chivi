require "pg"
require "json"

require "../../cv_env"
require "../../_util/hash_util"
require "../../_util/tran_util"

Log.setup_from_env

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

module YS::DBRepo
  extend self

  def get_wn_id(yb_id : Int32)
    PG_DB.query_one <<-SQL, yb_id, as: Int32
      select coalesce(nvinfo_id, 0) from ysbooks where id = $1
      SQL
  end

  def get_vl_id(yl_id : Bytes)
    PG_DB.query_one <<-SQL, yl_id, as: Int32
      select coalesce(id, 0) from yslists where yl_id = $1
      SQL
  end
end
