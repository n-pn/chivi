require "sqlite3"

class SP::WdDefn
  include DB::Serializable

  # property id : Int32 = 0

  property word : String
  property defn : String

  property mtime : Int64 = 0

  def initialize(@word, @defn, @mtime = Time.utc.to_unix)
  end

  def self.find(dict : String, word : String)
    query = "select * from terms where word = ?"
    open_db(dict, &.query_one?(query, word, as: self))
  end

  def self.upsert(dict : String, word : String, defn : String, mtime = Time.utc.to_unix)
    open_tx(dict) { |db| do_upsert(db, word, defn, mtime) }
  end

  def self.upsert(dict : String, items : Array(self))
    open_tx(dict) do |db|
      items.each { |item| do_upsert(db, item.word, item.defn, item.mtime) }
    end
  end

  def self.do_upsert(db : DB::Database, word : String, defn : String, mtime : Int64)
    db.exec <<-SQL, word, defn, mtime
      insert into defns (word, defn, mtime) values (?, ?, ?)
      on conflict(word) do update set
        defn = defns.defn || char(13) || excluded.defn,
        mtime = excluded.mtime
      where defns.defn not like '%' || excluded.defn || '%'
    SQL
  end

  def self.remove_dup!(dict : String)
    open_tx(dict) do |db|
      changes = [] of Tuple(String, Int32)

      db.query_each "select id, defn from terms where defn like '%\n%'" do |rs|
        id, defn = rs.read(Int32, String)

        defns = defn.split('\n')
        defns_uniq = defns.uniq

        next if defns_uniq.size == defns.size
        changes << {defns_uniq.join('\n'), id}
      end

      update_query = "update terms set defn = ? where id = ?"
      changes.each { |defn, id| db.exec update_query, defn, id }

      puts "changed: #{changes.size}"
    end
  end

  ######

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/mtdic/fixed/defns/#{dname}.dic"
  end

  # open database for reading/writing
  def self.open_db(dname : String)
    db_path = self.db_path(dname)
    DB.open("sqlite3:#{db_path}") { |db| yield db }
  end

  # open database with transaction for writing
  def self.open_tx(dname : String)
    open_db(dname) do |db|
      db.exec "pragma synchronous = normal"
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.init_db(dname : String, reset : Bool = false)
    open_db(dname) do |db|
      db.exec "drop table if exists defns" if reset
      db.exec "pragma journal_mode = WAL"

      db.exec <<-SQL
        create table if not exists defns (
          id integer primary key,
          word varchar not null unique,
          defn varchar not null,
          _etc varchar default '',
          mtime integer not null default 0
        )
      SQL
    end
  end
end
