require "../../_data/_data"

struct RD::Rdchap
  include JSON::Serializable

  getter title : String = ""
  getter p_idx : Int32 = 1
  getter rmode : String = "qt"
  getter qt_rm : String = "qt_v1"
  getter mt_rm : String = "mtl_1"

  def initialize
  end

  def to_db
    self.to_json
  end

  def self.to_db(val : self)
    val.to_json
  end

  def self.to_db(val : Nil)
    "{}"
  end

  def self.from_rs(rs : DB::ResultSet)
    new(rs.read(JSON::PullParser))
  end
end

class RD::Rdmemo
  ############

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "rdmemos", :postgres, strict: false

  field vu_id : Int32 = 0, pkey: true
  field sname : String = "", pkey: String
  field sn_id : String = "", pkey: true

  field vname : String = ""
  field rpath : String = ""

  field rstate : Int16 = 0
  field rating : Int16 = 0
  field recomm : Int16 = 0

  field view_count : Int32 = 0
  field coin_spent : Int32 = 0

  field last_ch_no : Int32 = 0
  field last_cinfo : Rdchap? = nil, converter: RD::Rdchap

  field mark_ch_no : Int32 = 0
  field mark_cinfo : Rdchap? = nil, converter: RD::Rdchap

  field atime : Int64 = 0
  field rtime : Int64 = 0

  def initialize(@vu_id, @sname, @sn_id)
    @last_cinfo = Rdchap.new
    @mark_cinfo = Rdchap.new
  end

  def inherit(mform : self, action : String = "")
    case action
    when "rstate"
      @rstate = mform.rstate
    when "rating"
      @rating = mform.rating
    when "recomm"
      @recomm = mform.recomm
    when "chmark", "chlast"
      @rtime = Time.utc.to_unix

      @vname = mform.vname
      @rpath = mform.rpath

      @last_ch_no = mform.last_ch_no
      @last_cinfo = mform.last_cinfo

      if action == "chmark" || self.sequence_read?(mform.last_ch_no)
        @mark_ch_no = mform.mark_ch_no
        @mark_cinfo = mform.mark_cinfo
      end
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

  def self.find(vu_id : Int32, sname : String, sn_id : String)
    return nil if vu_id < 1
    self.get(vu_id, sname, sn_id, db: @@db) do |sql|
      sql << "where vu_id = $1 and sname = $2 and sn_id = $3"
    end
  end

  def self.load(vu_id : Int32, sname : String, sn_id : String)
    self.find(vu_id, sname, sn_id) || new(vu_id, sname, sn_id)
  end

  def self.get_all(vu_id : Int32, sname : Nil, rtype : String = "", limit : Int32 = 20, offset : Int32 = 0)
    self.get_all(vu_id, limit, offset) do |sql|
      sql << " where vu_id = $1"
      case rtype
      when "liked" then sql << " and recomm > 0"
      when "rdlog" then sql << " and last_ch_no > 0"
      end
      sql << " order by rtime desc limit $2 offset $3"
    end
  end

  def self.get_all(vu_id : Int32, sname : String, rtype : String = "", limit : Int32 = 20, offset : Int32 = 0)
    self.get_all(vu_id, sname, limit, offset) do |sql|
      sql << " where vu_id = $1 and sname like $2 || '%'"
      case rtype
      when "liked" then sql << " and recomm > 0"
      when "rdlog" then sql << " and last_ch_no > 0"
      end
      sql << " order by rtime desc limit $3 offset $4"
    end
  end
end
