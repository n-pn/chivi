require "sqlite3"

class TL::TlTerm
  include DB::Serializable

  # property id : Int32 = 0

  property word : String
  property defn : String
  property utime : Int64 = 0

  def initialize(@word, @defn, @utime = Time.utc.to_unix)
  end

  def self.find(dict : String, word : String)
    open_db(dict, &.query_one?("select * from terms where word = ?", [word], as: self))
  end

  def self.upsert(dict : String, word : String, defn : String, utime = Time.utc.to_unix)
    open_db(dict) do |db|
      do_upsert(db, word, defn, utime)
    end
  end

  def self.upsert_bulk(dict : String, items : Array(TlTerm))
    open_db(dict) do |db|
      db.exec "begin transaction"

      items.each do |item|
        do_upsert(db, item.word, item.defn, item.utime)
      end

      db.exec "commit"
    end
  end

  def self.do_upsert(db : DB::Database, word : String, defn : String, utime : Int64)
    # note: using verticle tab (`\v`) to seperate entries

    db.exec <<-SQL, args: [word, defn, utime]
      insert into terms(word, defn, utime) values (?, ?, ?)
      on conflict(word) do update set
        defn = terms.defn || char(11) || excluded.defn,
        utime = excluded.utime
      where terms.defn <> excluded.defn
    SQL
  end

  ######

  @[AlwaysInline]
  def self.db_path(dict : String)
    "var/mtkit/#{dict}.db"
  end

  def self.open_db(dict : String)
    db_path = self.db_path(dict)
    DB.open("sqlite3://./#{db_path}") { |db| yield db }
  end

  def self.init_db(dict : String, reset : Bool = false)
    open_db(dict) do |db|
      db.exec <<-SQL
        create table if not exists terms (
          id integer primary key,
          word varchar not null unique,
          defn varchar not null,
          utime integer not null default 0
        )
      SQL

      if reset
        db.exec "delete from terms"
        db.exec "drop table if exists sqlite_sequence"
      end
    end
  end
end
