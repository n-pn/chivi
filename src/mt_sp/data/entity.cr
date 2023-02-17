require "sqlite3"

class SP::Entity
  include DB::Serializable

  # property id : Int32 = 0

  property form : String
  property etag : String

  property extra : String = ""
  property mtime : Int64 = 0

  def initialize(@form, @etag, @extra = "", @mtime = Time.utc.to_unix)
  end

  def self.find(form : String)
    query = "select * from entities where form = ?"
    open_db(dict, &.query_one?(query, word, as: self))
  end

  def self.upsert(form : String, etag : String, extra : String)
    open_tx { |db| do_upsert(db, form, etag, extra) }
  end

  def self.upsert(items : Array(self))
    open_tx do |db|
      items.each { |item| do_upsert(db, item.form, item.etag, item.extra) }
    end
  end

  def self.do_upsert(db : DB::Database, form : String, etag : String, extra : String)
    db.exec(<<-SQL, form, etag, extra, Time.utc.to_unix)
      insert into entities (form, etag, extra, mtime) values (?, ?, ?, ?)
      on conflict(form, etag) do update set extra = excluded.extra
    SQL
  end

  ######

  # return path for database
  @[AlwaysInline]
  def self.db_path
    "var/dicts/defns/entities.dic"
  end

  # open database for reading/writing
  def self.open_db
    DB.open("sqlite3:#{self.db_path}") { |db| yield db }
  end

  # open database with transaction for writing
  def self.open_tx
    open_db do |db|
      db.exec "pragma synchronous = normal"
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.init_db(reset : Bool = false)
    open_db do |db|
      db.exec "drop table if exists entities" if reset
      db.exec "pragma journal_mode = WAL"

      db.exec <<-SQL
        create table entities (
          id integer primary key,
          --
          form varchar not null,
          stem varchar not null default '',
          --
          etag varchar not null,
          ptag varchar not null default '',
          --
          extra varchar not null default '',
          mtime integer not null default 0
        )
      SQL

      db.exec "create unique index word_idx on entities(form, etag)"
      db.exec "create index etag_idx on entities(etag)"
    end
  end

  # init_db(reset: true)
end
