require "crorm"
require "./zv_term"

class MT::ZvDict
  DIR = ENV.fetch("MT_DIR", "var/mt_db")
  class_getter db_path = "#{DIR}/zdinfos.db3"

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS zdinfos (
      name text NOT NULL primary key,
      kind int NOT NULL DEFAULT 0,
      d_id int NOT NULL DEFAULT 0,
      --
      label text NOT NULL DEFAULT '',
      brief text NOT NULL DEFAULT '',
      p_min int not null default 0,
      --
      total int NOT NULL DEFAULT 0,

      --
      users text NOT NULL DEFAULT '',
      mtime int NOT NULL DEFAULT 0
    ) strict, without rowid;

    CREATE INDEX IF NOT EXISTS type_idx ON zdinfos (kind);
    CREATE INDEX IF NOT EXISTS show_idx ON zdinfos (mtime);
  SQL

  ######

  include Crorm::Model
  schema "zdinfos", :sqlite, multi: false

  field name : String, pkey: true
  field kind : Int32 = 0
  field d_id : Int32 = 0 # unique by kind

  field p_min : Int32 = 0
  field label : String = ""
  field brief : String = ""

  field total : Int32 = 0
  field mtime : Int32 = 0
  field users : String = ""

  def initialize(@name, @kind, @d_id, @label = "", @brief = "")
    case @kind
    when 0 then @p_min = 2
    when 1 then @p_min = 1
    else        @p_min = 0
    end
  end

  @[DB::Field(ignore: true, auto: true)]
  getter term_db : Crorm::SQ3 { ZvTerm.load_db(@kind) }

  UPDATE_STATS_SQL = <<-SQL
    update zdinfos
    set mtime = $1, total = total + $2
    where "name" = $3
    returning total
    SQL

  def update_stats!(@mtime : Int32, change : Int32 = 1)
    @total = self.class.db.open_rw(&.query_one UPDATE_STATS_SQL, mtime, change, as: Int32)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "name", @name
      jb.field "kind", @kind
      jb.field "d_id", @d_id

      jb.field "p_min", @p_min
      jb.field "label", @label
      jb.field "brief", @brief

      jb.field "total", @total
      jb.field "mtime", ZvUtil.utime(@mtime)
      # jb.field "users", @users.split(',')
    end
  end

  ###

  DB_CACHE = {} of String => self

  def self.load!(name : String, db = self.db)
    DB_CACHE[name] ||= find(name, db: db) || begin
      case name
      when .starts_with?("wn") then new(name, kind: 2, d_id: name[2..].to_i)
      when .starts_with?("up") then new(name, kind: 3, d_id: name[2..].to_i)
      when .starts_with?("qt") then new(name, kind: 4, d_id: name[2..].to_i)
      when .starts_with?("pd") then new(name, kind: 5, d_id: name[2..].to_i)
      else                          raise "dict name not allowed: #{name}"
      end
    end
  end

  def self.find(name : String, db = self.db) : self | Nil
    self.get(name, db: db, &.<< " where name = $1")
  end

  def self.find!(name : String, db = self.db) : self
    self.get!(name, db: db, &.<< " where name = $1")
  end

  COUNT_SQL = "select coalesce(count(*), 0) from zdinfos "

  def self.count(kind : String) : Int32
    case kind
    when "wn"
      query = "#{COUNT_SQL} where kind = 2"
    when "up"
      query = "#{COUNT_SQL} where kind = 3"
    when "qt"
      query = "#{COUNT_SQL} where kind = 4"
    when "pd"
      query = "#{COUNT_SQL} where kind = 5"
    else
      query = "#{COUNT_SQL} where kind < 2"
    end

    @@db.query_one(query, as: Int32)
  end

  # def self.get_all(limit = 50, offset = 0) : Array(self)
  #   self.get_all limit, offset do |sql|
  #     sql << " where total > 0 order by mtime desc limit $1 offset $2"
  #   end
  # end

  def self.fetch_all(kind : String, limit = 25, offset = 0) : Array(self)
    case kind
    when "wn" then get_all(2, limit, offset)
    when "up" then get_all(3, limit, offset)
    else           get_core()
    end
  end

  def self.get_all(kind : Int32, limit = 50, offset = 0)
    self.get_all kind, limit, offset do |sql|
      sql << " where kind = $1 order by mtime desc, total desc limit $2 offset $3"
    end
  end

  def self.get_core
    self.get_all(&.<< " where kind < 2 order by d_id asc")
  end

  def self.init_wn_dict!(wn_id : Int32, bname : String, db = self.db)
    dict = self.load!("wn#{wn_id}", db: db)
    dict.label = bname
    dict.brief = "Từ điển riêng cho bộ truyện chữ [#{bname}]"
    dict.upsert!(db: db)
    dict
  end

  def self.init_up_dict!(up_id : Int32, bname : String, db = self.db)
    dict = self.load!("up#{up_id}", db: db)
    dict.label = bname
    dict.brief = "Từ điển riêng cho sưu tầm cá nhân [#{bname}]"
    dict.upsert!(db: db)
    dict
  end
end
