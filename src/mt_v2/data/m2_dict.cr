require "log"
require "colorize"

require "crorm"
require "crorm/sqlite3"

class M2::CvDict
  include Crorm::Model
  @@table = "dicts"

  field id : Int32

  field name : String
  field slug : String = ""

  field label : String = ""
  field intro : String = ""

  field dsize : Int32 = 0
  field mtime : Int64 = 0

  def ininitialize(@id, @name, @slug, @label = "", @intro = "")
  end

  def save!(db = @@db)
    fields, values = get_changes
    db.upsert(fields, values) do |sql|
      Crorm::SqlBuilder.build_upsert_sql(sql, ["name", "slug", "label", "intro"])
      sql << " where id == excluded.id"
    end
  end

  def bump!(@dsize, @mtime)
    @@db.exec <<-SQL, args: [dsize, mtime, id]
      update dicts set dsize = ?, mtime = ? where id = ?
    SQL
  end

  def tuple
    {@name, @label, @dsize, @intro}
  end

  ######

  class_getter db = Crorm::Sqlite3::Repo.new("var/dicts/dicts_v2.db")

  DICT_IDS = {} of String => Int32

  def self.id_of(name : String) : Int32
    DICT_IDS[name] ||= begin
      query = "select id from dicts where name = ?"
      @@db.open(&.query_one?(query, args: [name], as: Int32)) || 0
    end
  end

  def self.get!(id : Int32)
    @@db.open(&.query_one("select * from dicts where id = ?", args: [id], as: CvDict))
  end

  def self.find(name : String)
    find!(name)
  rescue
    nil
  end

  def self.find!(name : String)
    @@db.open(&.query_one(%{select * from dicts where name = ?}, args: [name], as: CvDict))
  end

  def self.total_books
    @@db.open(&.query_one "select count(*) from dicts where dsize > 0 and id < 0", as: Int32)
  end

  def self.fetch_books(limit : Int32, offset = 0)
    query = <<-SQL
      select * from dicts where id < 0 and dsize > 0
      order by mtime desc
      limit ? offset ?
    SQL

    @@db.open(&.query_all query, args: [limit, offset], as: CvDict)
  end
end
