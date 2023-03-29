require "sqlite3"

class MT::TxTerm
  include DB::Serializable

  getter zstr : String
  getter type : Int32 = 0

  getter ztag : String

  getter freq : Int32 = 0
  getter occu : Int32 = 0

  getter flag : Int32 = 0

  def initialize(@zstr, @type, @ztag)
  end

  def self.db_path(wn_id : String | Int32)
    "var/anlzs/texsmart/out/#{wn_id}.db"
  end

  def self.open_db(wn_id : String | Int32)
    db_path = self.db_path(wn_id)
    existed = File.file?(db_path)

    db = DB.open("sqlite3:#{db_path}?journal_mode=WAL&synchronous=normal")
    db.exec(self.init_sql) unless existed
    db
  end

  def self.init_sql
    <<-SQL
      create table terms(
        "zstr" varchar not null,
        "type" integer not null,
        "ztag" varchar not null,

        "count" integer not null default 0,
        "mrate" integer not null default 0,

        "_flag" integer not null default 0,

        primary key ("zstr", "type", "ztag")
      );
    SQL
  end

  def self.upsert_stmt
    <<-SQL
      insert into terms ("zstr", "type", "ztag", "count", "mrate") values ($1, $2, $3, $4, $5)
      on conflict do update set "count" = excluded.count, "mrate" = excluded.mrate
    SQL
  end

  def self.upsert(zstr : String, type : Int32, ztag : String, count : Int32, mrate : Int32, db)
    db.exec self.upsert_stmt, zstr, type, ztag, count, mrate
  end
end
