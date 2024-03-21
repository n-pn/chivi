require "crorm"
require "../../_util/time_util"
require "../../_util/http_util"

class RD::Cvtran
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS cvtran(
      zstr text NOT NULL DEFAULT '' primary key,
      vstr text not null default '',

      kind int not null default 0,
      time int not null default 0
    ) strict, without rowid;
    SQL

  CZ_DIR = "/2tb/zroot/wn_db"

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32)
    "#{CZ_DIR}/#{sname}/#{sn_id}-vtran.db3"
  end

  @[AlwaysInline]
  def self.db(sname : String, sn_id : String | Int32)
    self.db(self.db_path(sname, sn_id))
  end

  @[AlwaysInline]
  def self.db(db_path : String)
    Crorm::SQ3.new(db_path, &.init_db(self.init_sql))
  end

  include Crorm::Model
  schema "cvtran", :sqlite, multi: true

  field zstr : String, pkey: true
  field vstr : String = ""

  field kind : Int32 = 0
  field time : Int32 = 0

  def initialize(@zstr, @vstr = "", @kind = 0, @time = TimeUtil.cv_mtime)
  end

  UPSERT_SQL = <<-SQL
    insert into cvtran(zstr, vstr, kind, "time")
    values ($1, $2, $3, $4)
    on conflict(zstr) do update
    set vstr = excluded.vstr, kind = excluded.kind, "time" = excluded.time
    where excluded.kind >= cvtran.kind
  SQL

  def upsert!(db)
    db.exec UPSERT_SQL, @zstr, @vstr, @kind, @time
    self
  end

  ###

  GET_TRAN_SQL = query = "select vstr from cvtran where zstr = $1 limit 1"

  def self.get_trans(repo : Crorm::DBX, zdata : Array(String), wn_id : Int32 = 0)
    results = {} of String => String
    missing = [] of String

    repo.open_ro do |db|
      zdata.each do |zstr|
        if vstr = db.query_one?(GET_TRAN_SQL, zstr, as: String)
          results[zstr] = vstr
        else
          missing << zstr
        end
      end
    end

    return results if missing.empty?

    q_url = "#{CV_ENV.m1_host}/_m1/qtran?wn=#{wn_id}&hs=#{missing.size}&op=txt"
    vtran = HTTP::Client.post(q_url, body: missing.join('\n'), &.body_io.gets_to_end.lines)

    to_save = missing.map_with_index do |zstr, l_id|
      vstr = vtran[l_id]
      results[zstr] = vstr
      self.new(zstr: zstr, vstr: vstr)
    end

    spawn do
      repo.open_tx { |tx| to_save.each(&.upsert!(db: tx)) }
    rescue ex
      Log.error(exception: ex) { ex.message }
    end

    results
  end
end
