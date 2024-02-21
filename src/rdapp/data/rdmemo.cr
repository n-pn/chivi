require "../../_data/_data"

class RD::Rdmemo
  ############

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "rdmemos", :postgres, strict: false

  field vu_id : Int32 = 0, pkey: true
  field sname : String, pkey: true
  field sn_id : Int32, pkey: true

  field rd_id : Int32 = 0

  field rd_track : Int16 = 0
  field rd_state : Int16 = 0
  field rd_stars : Int16 = 0

  field rmode : String = "qt"
  field qt_rm : String = "qt_v1"
  field mt_rm : String = "mtl_1"

  field lc_mtype : Int16 = 0 # last chap mark type

  field lc_title : String = "" # last chap title
  field lc_ch_no : Int32 = 0   # last chap index
  field lc_p_idx : Int16 = 0   # last chap part no

  field view_count : Int32 = 0
  field coin_spent : Int32 = 0

  field atime : Int64 = 0
  field rtime : Int64 = 0

  def initialize(@vu_id, @sname, @sn_id)
  end

  def inherit(mform : self, action : String = "")
    case action
    when "rstate"
      @rd_state = mform.rd_state
    when "rating"
      @rd_stars = mform.rd_stars
    when "follow"
      @rd_track = mform.rd_track
    when "chmark"
      @rd_id = mform.rd_id
      @rtime = Time.utc.to_unix

      @lc_mtype = mform.lc_mtype
      @lc_title = mform.lc_title
      @lc_ch_no = mform.lc_ch_no
      @lc_p_idx = mform.lc_p_idx

      @rmode = mform.rmode
      @qt_rm = mform.qt_rm
      @mt_rm = mform.mt_rm
    end

    self
  end

  def sequence_read?(ch_no : Int32)
    @mark_ch_no == ch_no || @mark_ch_no == ch_no &- 1
  end

  UPDATE_FIELD_SQL = "update #{@@schema.table} set %s = $1 where vu_id = $2 and sname = $3 and sn_id = $4"

  def update_atime!(@atime = Time.utc.to_unix)
    query = UPDATE_FIELD_SQL % "atime"
    @@db.exec query, atime, @vu_id, @sname, @sn_id
    self
  end

  ###

  def self.find(vu_id : Int32, sname : String, sn_id : Int32)
    return nil if vu_id < 1
    self.get(vu_id, sname, sn_id, db: @@db) do |sql|
      sql << " where vu_id = $1 and sname = $2 and sn_id = $3"
    end
  end

  def self.load!(vu_id : Int32, sname : String, sn_id : Int32)
    rmemo = self.find(vu_id, sname, sn_id) || new(vu_id, sname, sn_id)
    rmemo.tap(&.update_atime!)
  end

  def self.get_all(vu_id : Int32, sname : Nil, rtype : String = "", limit : Int32 = 20, offset : Int32 = 0)
    self.get_all(vu_id, limit, offset) do |sql|
      sql << " where vu_id = $1"
      case rtype
      when "liked" then sql << " and rd_track > 0"
      when "rdlog" then sql << " and lc_ch_no > 0"
      end
      sql << " order by rtime desc limit $2 offset $3"
    end
  end

  def self.get_all(vu_id : Int32, stype : String = "",
                   state : Int32 = -1, rtype : String = "",
                   order : String = "",
                   limit : Int32 = 20, offset : Int32 = 0)
    self.get_all(vu_id, limit, offset) do |sql|
      sql << " where vu_id = $1 and rd_id > 0"
      case stype
      when "wn" then sql << " and sname like '~%'"
      when "up" then sql << " and sname like '@%'"
      when "rm" then sql << " and sname like '!%'"
      end

      sql << " and rd_state = #{state}" if state > -1

      case rtype
      when "liked" then sql << " and rd_track > 0"
      when "rdlog" then sql << " and lc_ch_no > 0"
      end

      case order
      when "atime" then sql << " order by atime desc"
      else              sql << " order by rtime desc"
      end

      sql << " limit $2 offset $3"
    end
  end

  def self.get_vu_id(uname : String)
    PGDB.query_one?("select id from viusers where uname = $1", uname, as: Int32)
  end

  def self.fetch_all(vu_id : Int32, rd_ids : Array(Int32))
    self.get_all(vu_id, rd_ids, db: self.db, &.<< "where vu_id = $1 and rd_id = any($2)")
  end
end
