require "crorm"
require "crorm/sqlite3"

class YS::YsUser
  include Crorm::Model

  @@table = "users"

  field id : Int32

  field zname : String
  field vname : String = ""
  field vslug : String = ""

  field like_count : Int32 = 0
  field star_count : Int32 = 0

  field list_total : Int32 = 0
  field list_count : Int32 = 0

  field crit_total : Int32 = 0
  field crit_count : Int32 = 0

  field repl_total : Int32 = 0
  field repl_count : Int32 = 0

  field list_rtime : Int64 = 0
  field crit_rtime : Int64 = 0
  field repl_rtime : Int64 = 0

  field rtime : Int64 = 0
  field mtime : Int64 = 0

  # def fix_name : Nil
  #   # TODO: revemo CV::BookUtil
  #   self.vname = CV::BookUtil.hanviet(self.zname, caps: true)
  #   self.vslug = CV::BookUtil.scrub_vname(self.vname, "-")
  # end

  ###

  def self.open_db(db_path = self.db_path)
    DB.open("sqlite3:#{db_path}") { |db| yield db }
  end

  def self.open_tx(db_path = self.db_path)
    open_db(db_path) do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.db_path
    "var/ysapp/users.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_ys_user.sql") }}
  end

  RAW_UPSERT_FIELDS = {
    "id", "zname", "avatar",
    "like_count", "star_count",
    "list_total", "crit_total",
    "rtime", "mtime",
  }

  def self.upsert_sql(fields : Enumerable(String) = RAW_UPSERT_FIELDS) : String
    String.build do |sql|
      sql << "insert into users ("
      fields.join(sql, ", ")
      sql << ") values ("

      fields.join(sql, ", ") { |_, io| io << '?' }
      sql << ") on conflict (id) do update set "

      fields.join(sql, ", ") { |f, io| io << f << " = excluded." << f }
    end
  end

  ###############
  # def self.upsert!(id : Int32, zname : String)
  #   find({zname: zname}) || begin
  #     entry = new({origin_id: origin_id, zname: zname}).tap(&.fix_name)
  #     entry.tap(&.save!)
  #   end
  # end
end
