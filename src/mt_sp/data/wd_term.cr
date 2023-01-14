require "sqlite3"

class SP::WdTerm
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

  def self.upsert_bulk(dict : String, items : Array(LuTerm))
    open_db_tx(dict) do |db|
      items.each do |item|
        do_upsert(db, item.word, item.defn, item.utime)
      end
    end
  end

  def self.do_upsert(db : DB::Database, word : String, defn : String, utime : Int64)
    # note: using verticle tab (`\v`) to seperate entries

    db.exec <<-SQL, word, defn, utime
      insert into terms(word, defn, utime) values (?, ?, ?)
      on conflict(word) do update set
        defn = terms.defn || char(11) || excluded.defn,
        utime = excluded.utime
      where terms.defn not like '%' || excluded.defn || '%'
    SQL
  end

  def self.remove_dup!(dict : String)
    open_db_tx(dict) do |db|
      changes = [] of Tuple(String, Int32)

      db.query_each "select id, defn from terms where defn like '%\v%'" do |rs|
        id, defn = rs.read(Int32, String)

        defs = defn.split('\v')
        defu = defs.uniq

        next if defu.size == defs.size
        changes << {defu.join('\v'), id}
      end

      update_query = "update terms set defn = ? where id = ?"

      changes.each do |defn, id|
        db.exec update_query, args: [defn, id]
      end

      puts "changed: #{changes.size}"
    end
  end

  ######

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/dicts/defns/#{dname}.dic"
  end

  # open database for reading/writing
  def self.open_db(dname : String)
    db_path = self.db_path(dname)
    DB.open("sqlite3:#{db_path}") { |db| yield db }
  end

  # open database with transaction for writing
  def self.open_db_tx(dict : String)
    open_db(dict) do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.init_db(dict : String, reset : Bool = false)
    open_db(dict) do |db|
      db.exec "delete table if exists terms" if reset

      db.exec <<-SQL
        create table if not exists terms (
          id integer primary key,
          word varchar not null unique,
          defn varchar not null,
          utime integer not null default 0
        )
      SQL
    end
  end
end
