require "crorm"
require "crorm/sqlite3"

require "../../mt_sp/sp_core"
require "../../_util/text_util"

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

  VNAME_UPDATE_SQL = <<-SQL
    update #{@@table} set vname = ?, vslug = ?
    where id = ?
  SQL

  STATS_UPDATE_SQL = <<-SQL
    update users set crit_total = $1, crit_rtime = $2
    where id = $3
  SQL

  def db_names
    vname = translit(self.zname)
    vslug = TextUtil.slugify(vname)

    {vname, vslug}
  end

  private def translit(name : String)
    return name unless name =~ /\p{Han}/
    SP::MtCore.tl_sinovi(name, true)
  end

  ###

  def self.open_db(db_path = self.db_path, &)
    DB.open("sqlite3:#{db_path}") { |db| yield db }
  end

  def self.open_tx(db_path = self.db_path, &)
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
