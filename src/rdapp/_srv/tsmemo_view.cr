require "../../_data/_data"

class RD::TsmemoView
  class_getter db : DB::Database = PGDB

  include DB::Serializable
  include DB::Serializable::NonStrict

  include JSON::Serializable

  getter sroot : String

  getter stype : Int16
  getter sn_id : Int32
  getter sname : String

  getter vname : String = ""
  getter cover : String = ""

  getter chmax : Int32 = 0
  getter mtime : Int64 = 0_i64

  ###

  getter rd_track : Int16
  getter rd_state : Int16
  getter rd_stars : Int16

  getter rmode : String
  getter qt_rm : String
  getter mt_rm : String

  getter lc_mtype : Int16

  getter lc_title : String
  getter lc_ch_no : Int32
  getter lc_p_idx : Int16

  getter vu_atime : Int64
  getter vu_rtime : Int64

  private def self.select_sql(&)
    String.build do |sql|
      sql << <<-SQL
      select
        t.sroot,
        t.stype,
        t.sn_id,
        t.sname,
        t.vname,
        t.cover,
        t.chmax,
        t.mtime,

        coalesce(m.rd_track, 0::smallint) as rd_track,
        coalesce(m.rd_state, 0::smallint) as rd_state,
        coalesce(m.rd_stars, 0::smallint) as rd_stars,

        coalesce(m.rmode, 'qt') as rmode,
        coalesce(m.qt_rm, 'qt_v1') as qt_rm,
        coalesce(m.mt_rm, 'mtl_1') as mt_rm,

        coalesce(m.lc_mtype, 0::smallint) as lc_mtype,
        coalesce(m.lc_title, '') as lc_title,
        coalesce(m.lc_ch_no, 0) as lc_ch_no,
        coalesce(m.lc_p_idx, 1::smallint) as lc_p_idx,

        coalesce(m.atime, 0::bigint) as vu_atime,
        coalesce(m.rtime, 0::bigint) as vu_rtime

      from tsrepos as t
      left join rdmemos as m
        on m.sname = t.sname
        and m.sn_id = t.sn_id
        and m.vu_id = $1
      SQL

      yield sql
    end
  end

  def self.get_all(vu_id : Int32,
                   stype = -1, state = -1,
                   rtype = "", order = "",
                   limit = 20, offset = 0)
    args = [vu_id] of Int32 | String
    query = select_sql do |sql|
      sql << " where 1 = 1"

      if stype >= 0
        args << stype
        sql << " and t.stype = $2"
      end

      if state >= 0
        args << state
        sql << " and m.rd_state = $#{args.size}"
      end

      case rtype
      when "liked" then sql << " and m.rd_track > 0"
      when "rdlog" then sql << " and m.lc_ch_no > 0"
      end

      case order
      when "mtime" then sql << " order by t.mtime desc"
      when "atime" then sql << " order by m.atime desc"
      when "rtime" then sql << " order by m.rtime desc"
      end

      args << limit
      sql << " limit $#{args.size}"
      args << offset
      sql << " offset $#{args.size}"
    end

    PGDB.query_all(query, args: args, as: self)
  end
end
