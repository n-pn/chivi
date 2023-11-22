require "crorm"

class MT::ViDict
  def self.min_privi(dname : String)
    case dname
    when "regular", "suggest"  then 1
    when .starts_with?("book") then 0
    when .starts_with?("wn")   then 0
    when .starts_with?("priv") then 0
    when .starts_with?("up")   then 0
    else                            2
    end
  end

  enum Dtype
    None = 0
    Core = 1
    Book = 2
    Priv = 3
    Rand = 4
    Uniq = 5

    def self.from_name(dname : String)
      case dname
      when .starts_with?("book") then Book
      when .starts_with?("wn")   then Book
      when .starts_with?("priv") then Priv
      when .starts_with?("up")   then Priv
      when .starts_with?("rand") then Rand
      else                            Uniq
      end
    end
  end

  class_getter db_path = "var/mt_db/vi_dicts.db3"

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS dicts (
      dname varchar NOT NULL primary key,
      dtype integer NOT NULL DEFAULT 0,
      --
      label varchar NOT NULL DEFAULT '',
      descs varchar NOT NULL DEFAULT '',
      --
      users varchar NOT NULL DEFAULT '',
      total integer NOT NULL DEFAULT 0,
      mtime integer NOT NULL DEFAULT 0,
      --
      _flag integer NOT NULL DEFAULT 0
    );

    CREATE INDEX IF NOT EXISTS type_idx ON dicts (dtype, total);
    CREATE INDEX IF NOT EXISTS show_idx ON dicts (mtime, total);
  SQL

  ######

  include Crorm::Model
  schema "dicts"

  field dname : String, pkey: true
  field dtype : Int32 = 0 # map with Dtype enum

  field label : String = ""
  field descs : String = ""

  field total : Int32 = 0
  field mtime : Int32 = 0
  field users : String = ""

  field _flag : Int32 = 0

  def initialize(@dname, dtype : Dtype = Dtype.from_name(dname))
    @dtype = dtype.to_i
  end

  def initialize(@dname, dtype = Dtype.from_name(dname), @label = "", @descs = "")
    @dtype = dtype.to_i
  end

  # def set_term!(Vi)

  def update_stats!(@mtime : Int32, change : Int32 = 1)
    self.class.bump_stats!(dname: @dname, mtime: mtime, change: change)
    @total = total
    self
  end

  # def update_stats!(@mtime : Int64)
  #   @total = self.class.db.bump_stats!(dname: @dname, mtime: mtime)
  # end

  def self.bump_stats!(dname : String, mtime : Int64, change : Int32 = 1)
    query = <<-SQL
      update dicts
      set mtime = $1, total = total + $2
      where $dname = $3
      returning total
      SQL

    db.open_rw &.exec(query, mtime, change, dname)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "dname", @dname.sub('/', ':')
      jb.field "dtype", @dtype

      jb.field "label", @label
      jb.field "descs", @descs

      jb.field "total", @total
      jb.field "mtime", @mtime
    end
  end

  ####
  CACHE = {} of String => self

  def self.load(dname : String)
    CACHE[dname] ||= self.find(dname) || new(dname).insert!
  end

  def self.find(dname : String) : self | Nil
    self.get(dname, &.<< " where dname = $1")
  end

  def self.find!(dname : String) : self
    self.get!(dname, &.<< " where dname = $1")
  end

  def self.count : Int32
    query = "select count(*) from #{@@schema.table} where total > 0"
    @@db.query_one(query, as: Int32)
  end

  def self.count(dtype : Dtype) : Int32
    return self.count if dtype.none?
    query = "select count(*) from #{@@schema.table} where total > 0 and dtype == $1"
    @@db.query_one(query, dtype.to_i, as: Int32)
  end

  def self.get_all(limit = 50, offset = 0) : Array(self)
    self.get_all limit, offset do |sql|
      sql << " where total > 0 order by mtime desc limit $1 offset $2"
    end
  end

  def self.get_all(dtype : Dtype, limit = 50, offset = 0)
    return self.get_all(limit, offset) if dtype.none?
    self.get_all dtype.to_i, limit, offset do |sql|
      sql << " where dtype = $1 and total > 0 order by mtime desc limit $2 offset $3"
    end
  end

  def self.init_book_dict!(wn_id : Int32, bname : String, db = self.db)
    query = @@schema.upsert_stmt(keep_fields: %w(label descs))

    self.new(
      dname: "book/#{wn_id}",
      dtype: Dtype::Book,
      label: "Truyện: #{bname}",
      descs: "Từ điển riêng cho bộ truyện [#{bname}]",
    ).upsert!(query: query, db: db)
  end

  def self.init_up_dict!(up_id : Int32, bname : String, db = self.db)
    query = @@schema.upsert_stmt(keep_fields: %w(label descs))

    self.new(
      dname: "up/#{up_id}",
      dtype: Dtype::Priv,
      label: "Sưu tầm: #{bname}",
      descs: "Từ điển riêng cho sưu tầm cá nhân [#{bname}]",
    ).upsert!(query: query, db: db)
  end
end
