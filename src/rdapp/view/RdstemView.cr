require "json"
require "../../_data/_data"

struct RD::RdstemView
  include DB::Serializable
  include JSON::Serializable

  getter sname : String
  getter sn_id : String

  getter chmax : Int32 = 0
  getter utime : Int64 = 0

  getter multp : Int16 = 4
  getter privi : Int16 = 5
  getter gifts : Int16 = 2

  WN_SQL = <<-SQL
    select
      sname,
      wn_id::text as sn_id,
      chap_total as chmax,
      mtime as utime,
      multp,
      privi,
      2::smallint as gifts
    from wnseeds
    where wn_id = $1 and sname like '~%'
    SQL

  RM_SQL = <<-SQL
    select
      sname,
      sn_id,
      chap_count as chmax,
      update_int as utime,
      4::smallint as multp,
      3::smallint as privi,
      2::smallint as gifts

    from rmstems
    where wn_id = $1
    order by chap_count desc, update_int desc
    SQL

  UP_SQL = <<-SQL
    select
      sname,
      id::text as sn_id,
      chap_count as chmax,
      mtime as utime,
      multp,
      5::smallint as privi,
      gifts

    from upstems
    where wninfo_id = $1
    order by chap_count desc, mtime desc
    SQL

  def self.wstems_by_wn(wn_id : Int32)
    PGDB.query_all(WN_SQL, wn_id, as: self)
  end

  def self.rstems_by_wn(wn_id : Int32)
    PGDB.query_all(RM_SQL, wn_id, as: self)
  end

  def self.ustems_by_wn(wn_id : Int32)
    PGDB.query_all(UP_SQL, wn_id, as: self)
  end
end
