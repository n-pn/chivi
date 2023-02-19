require "json"
require "sqlite3"

class YS::YsBook
  include DB::Serializable

  getter id = 0
  getter cv_id = 0

  getter btitle = ""
  getter author = ""

  getter intro = ""
  getter genre = ""
  getter btags = ""

  getter cover = ""
  getter origs = ""

  getter voters = 0
  getter scores = 0

  getter status = 0
  getter udtime = 0_i64

  getter word_total = 0
  getter crit_total = 0
  getter list_total = 0

  getter crit_count = 0
  getter list_count = 0

  getter rprio = 0     # recrawling priority
  getter rtime = 0_i64 # last recrawled time

  getter stime = 0_i64 # sync to main database
  #####

  DB_PATH = "var/ysapp/books.db"

  def self.open_db
    DB.open "sqlite3:#{DB_PATH}" { |db| yield db }
  end

  def self.open_tx
    open_db do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.upsert_sql(fields : Enumerable(String))
    String.build do |sql|
      sql << "insert into books ("
      fields.join(sql, ", ")
      sql << ") values ("
      fields.join(sql, ", ") { |_, io| io << '?' }
      sql << ") on conflict (id) do update set "
      fields.join(sql, ", ") { |f, io| io << f << " = excluded." << f }
    end
  end

  def self.upsert!(fields : Array(String), values : Array(DB::Any))
    open_tx(&.exec(upsert_sql(fields), args: values))
  end
end
