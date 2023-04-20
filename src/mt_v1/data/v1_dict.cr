require "crorm"
require "crorm/sqlite3"

class M1::DbDict
  include Crorm::Model
  @@table = "dicts"

  field id : Int32, primary: true

  field dname : String = ""

  field label : String = ""
  field brief : String = ""

  field privi : Int32 = 0
  field dtype : Int32 = 0

  field term_total : Int32 = 0
  field term_avail : Int32 = 0

  field main_terms : Int32 = 0
  field temp_terms : Int32 = 0
  field user_terms : Int32 = 0

  field users : String = ""
  field mtime : Int64 = 0

  def initialize(@id, @dname, @label = "", @brief = "", @privi = 1, @dtype = 0)
  end

  def save!(repo : SQ3::Repo = self.class.repo)
    fields, values = db_changes
    smt = SQ3::SQL.upsert_smt(@@table, fields, "(id)", skip_fields: {"id"})
    repo.db.exec(smt, args: values)
  end

  def update!(changes : Hash(String, DB::Any))
    update!(changes.keys, changes.value)
  end

  def update!(fields : Enumerable(String), values : Enumerable(DB::Any))
    values << self.id!
    self.class.repo.update(@table, fields, values, where_clause: "id = ?")
  end

  def update_after_term_added!(@mtime : Int64, @term_total : Int32)
    smt = "update dicts set mtime = ?, term_total = ? where id = ?"
    self.class.repo.db.exec smt, mtime, term_total, self.id!
  end

  def update_after_term_added!(@mtime : Int64)
    update_smt = "update dicts set mtime = ?, term_total = term_total + 1 where id = ?"
    select_smt = "select term_total from dicts where id = ?"

    self.class.repo.open_db do |db|
      db.exec update_smt, mtime, self.id!
      @term_total = db.query_one(select_smt, self.id!, as: Int32)
    end
  end

  def to_json(jb)
    {@dname, @label, @term_total, @brief}.to_json(jb)
  end

  ######

  class_getter repo : SQ3::Repo do
    SQ3::Repo.new(self.db_path, self.init_sql, ttl: 3.minutes)
  end

  @[AlwaysInline]
  def self.db_path
    "var/mtdic/users/dicts_v1.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/dicts_v1.sql") }}
  end

  ####

  DICT_IDS = {} of String => Int32

  def self.get_id(dname : String) : Int32
    DICT_IDS[dname] ||= begin
      query = "select id from dicts where dname = ?"
      self.repo.open_db(&.query_one?(query, dname, as: Int32)) || 0
    end
  end

  def self.get_dname(id : Int32) : String
    get!(id).dname rescue "combine"
  end

  CACHED = {} of Int32 => self

  def self.load(id : Int32)
    CACHED[id] ||= get!(id)
  end

  def self.load(dname : String)
    load(get_id(dname))
  end

  def self.get!(id : Int32) : self
    query = "select * from dicts where id = ?"
    self.repo.open_db(&.query_one(query, id, as: self))
  end

  def self.get!(dname : String) : self
    query = "select * from #{@@table} where dname = ?"
    self.repo.open_db(&.query_one(query, dname, as: self))
  end

  def self.get(dname : String) : self | Nil
    get!(dname) rescue nil
  end

  def self.count : Int32
    query = "select count(*) from #{@@table} where term_total > 0"
    self.repo.open_db(&.query_one(query, as: Int32))
  end

  def self.books_count : Int32
    query = "select count(*) from #{@@table} where term_total > 0 and id > 0"
    self.repo.open_db(&.query_one(query, as: Int32))
  end

  def self.all(limit : Int32, offset = 0) : Array(self)
    query = <<-SQL
      select * from #{@@table} where term_total > 0
      order by mtime desc limit ? offset ?
    SQL

    self.repo.open_db(&.query_all(query, limit, offset, as: self))
  end

  def self.all_cores
    query = <<-SQL
      select * from #{@@table} where dtype = 0 or dtype = 1
      order by id asc
    SQL

    self.repo.open_db(&.query_all(query, as: self))
  end

  def self.all_books(limit : Int32, offset = 0)
    query = <<-SQL
      select * from #{@@table} where id > 0 and term_total > 0
      order by mtime desc limit ? offset ?
    SQL

    self.repo.open_db(&.query_all(query, limit, offset, as: self))
  end

  def self.init_wn_dict(wn_id : Int32, bslug : String, bname : String)
    new(
      id: wn_id,
      dname: "#{wn_id}-#{bslug}",
      label: bname,
      brief: "Từ điển riêng cho bộ truyện [#{bname}]",
      privi: 1,
      dtype: 3
    )
  end
end
