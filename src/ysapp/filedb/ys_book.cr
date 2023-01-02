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
  getter mtime = 0_i64

  getter word_total = 0
  getter crit_total = 0
  getter list_total = 0

  getter crit_count = 0
  getter list_count = 0

  getter cprio = 0     # crawl priority
  getter ctime = 0_i64 # crawl time
  getter stime = 0_i64 # sync to main database

  #####

  DB_PATH = "var/ysapp/books.db"

  def self.open_db
    DB.connect "sqlite3:./#{DB_PATH}" { |cnn| yield cnn }
  end

  def self.open_tx
    open_db do |cnn|
      cnn.exec "begin"
      yield cnn
      cnn.exec "commit"
    end
  end

  def self.upsert!(fields : Array(String), values : Array(DB::Any))
    query = String.build do |sql|
      sql << "insert into books("
      fields.join(sql, ", ")
      sql << ") values ("

      Array.new(fields.size, "?").join(sql, ",")
      sql << ") on conflict (id) do update set "

      fields.map { |f| "#{f} = excluded.#{f}" }.join(sql, ", ")
    end

    open_tx(&.exec(query, args: values))
  end
end
