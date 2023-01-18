require "crorm"
require "crorm/sqlite3"

class M2::DbDict
  include Crorm::Model
  @@table = "dicts"

  field id : Int32, primary: true

  field dname : String
  field label : String = ""
  field brief : String = ""
  field dslug : String = ""

  field privi : Int32 = 0
  field dtype : Int32 = 0

  field term_total : Int32 = 0
  field term_avail : Int32 = 0

  field base_terms : Int32 = 0
  field temp_terms : Int32 = 0
  field user_terms : Int32 = 0

  field users : String = ""
  field mtime : Int64 = 0

  def ininitialize(@id, @dname, @label = "", @brief = "", @privi = 1)
  end

  def save!(repo = @@repo)
    fields, values = get_changes

    repo.upsert(@@table, fields, values) do |sql|
      fields = {"dname", "label", "brief", "privi"}
      Crorm::SqlBuilder.build_upsert_sql(sql, fields)
      sql << " where dname == excluded.dname"
    end
  end

  def update!(changes : Hash(String, DB::Any))
    update!(changes.keys, changes.value)
  end

  def update!(fields : Enumerable(String), values : Enumerable(DB::Any))
    values << self.id!
    repo.update(@table, fields, values) { |sql| sql << " where id = ?" }
  end

  def bump!(@term_total, @mtime)
    update!({"term_total", "mtime"}, {term_total, mtime})
  end

  def tuple
    {@dname, @label, @term_total, @intro}
  end

  ######

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/dicts/v2raw/dicts_v2.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/dicts_v2.sql") }}
  end

  ####

  DICT_IDS = {} of String => Int32

  def self.get_id(dname : String) : Int32
    DICT_IDS[dname] ||= begin
      query = "select id from dicts where dname = ? limit 1"
      @@repo.open_db(&.query_one?(query, dname, as: Int32)) || 0
    end
  end

  def self.get!(id : Int32) : self
    query = "select * from dicts where id = ? limit 1"
    @@repo.open_db(&.query_one(query, id, as: self))
  end

  def self.get!(dname : String) : self
    query = "select * from #{@@table} where dname = ? limit 1"
    @@repo.open_db(&.query_one(query, dname, as: self))
  end

  def self.get(dname : String) : self | Nil
    find!(dname) rescue nil
  end

  def self.count : Int32
    query = "select count(*) from #{@@table} where term_total > 0"
    @@repo.open_db(&.query_one(query, as: Int32))
  end

  def self.bdicts_count : Int32
    query = "select count(*) from #{@@table} where term_total > 0 and id < 0"
    @@repo.open_db(&.query_one(query, as: Int32))
  end

  def self.all(limit : Int32, offset = 0) : Array(self)
    query = <<-SQL
      select * from #{@@table} where term_total > 0
      order by mtime desc limit ? offset ?
    SQL

    @@repo.open_db(&.query_all(query, limit, offset, as: self))
  end

  def self.bdicts_all(limit : Int32, offset = 0)
    query = <<-SQL
      select * from #{@@table} where id < 0 and term_total > 0
      order by mtime desc limit ? offset ?
    SQL

    @@repo.open_db(&.query_all(query, limit, offset, as: self))
  end
end
