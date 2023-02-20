require "sqlite3"

class SP::SpTerm
  include DB::Serializable
  class_getter table = "terms"

  property zstr : String
  property defs : String

  property tags : String = ""
  property sign : Int32 = 0

  property uname : String = ""
  property mtime : Int64 = 0

  def initialize(@zstr, @defs, @tags = "", @sign = 1, @uname = "", @mtime = Time.utc.to_unix)
  end

  def db_fields
    {"zstr", "defs", "tags", "sign", "uname", "mtime"}
  end

  def db_values
    {@zstr, @defs, @tags, @sign, @uname, @mtime}
  end

  # def self.find(dict : String, zstr : String)
  #   query = "select * from terms where zstr = ?"
  #   open_db(dict, &.query_one?(query, zstr, as: self))
  # end

  # def self.upsert(dict : String, zstr : String, defs : String, mtime = Time.utc.to_unix)
  #   open_tx(dict) { |db| do_upsert(db, zstr, defs, mtime) }
  # end

  # def self.upsert(dict : String, items : Array(self))
  #   open_tx(dict) do |db|
  #     items.each { |item| do_upsert(db, item.zstr, item.defs, item.mtime) }
  #   end
  # end

  # def self.do_upsert(db : DB::Database, zstr : String, defs : String, mtime : Int64)
  #   db.exec <<-SQL, zstr, defs, mtime
  #     insert into terms (zstr, defs, mtime) defsues (?, ?, ?)
  #     on conflict(zstr) do update set
  #       defs = terms.defs || char(13) || excluded.defs,
  #       mtime = excluded.mtime
  #     where terms.defs not like '%' || excluded.defs || '%'
  #   SQL
  # end

  UPSERT_FIELDS = {"zstr", "defs", "tags", "sign", "uname", "mtime"}

  def self.upsert_sql
    <<-SQL
    insert into "#{@@table}" ("zstr", "defs", "tags", "sign", "uname", "mtime")
    values ($1, $2, $3, $4, $5, $6)
    on conflict("zstr", "uname")do update set
      "defs" = excluded.defs,
      "tags" = excluded.tags,
      "sign" = excluded.sign,
      "mtime" = excluded.mtime
    SQL
  end

  ######

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/dicts/spdic/#{dname}.dic"
  end

  def self.open_db(dname : String)
    DB.open("sqlite3:#{self.db_path(dname)}")
  end

  # open database for reading/writing
  def self.open_db(dname : String, &)
    DB.open("sqlite3:#{self.db_path(dname)}") { |db| yield db }
  end

  # open database with transaction for writing
  def self.open_tx(dname : String, &)
    open_db(dname) do |db|
      db.exec "pragma synchronous = normal"
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.init_db(dname : String, reset : Bool = false)
    open_db(dname) do |db|
      db.exec "drop table if exists terms" if reset
      db.exec "pragma journal_mode = WAL"

      db.exec <<-SQL
        create table if not exists terms (
          "zstr" varchar not null,
          "defs" varchar not null,
          --
          "tags" varchar not null default '',
          "sign" integer not null default 0,
          --
          "mtime" bigint not null default 0,
          "uname" varchar not null default '',
          --
          primary key("zstr", "uname")
        )
      SQL
    end
  end
end
