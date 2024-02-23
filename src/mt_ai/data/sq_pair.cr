require "crorm"
require "./db_util"

struct MT::SqPair
  DIR = "var/mtdic"

  class_getter db_path = "#{DIR}/zvpairs.db3"

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS zvpairs (
      dname text NOT NULL,
      a_key text NOT NULL,
      b_key text NOT NULL,
      --
      a_vstr text NOT NULL,
      a_attr text,
      b_vstr text,
      b_attr text,
      --
      uname text NOT NULL DEFAULT '',
      mtime int NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0,
      primary key(dname, a_key, b_key)
    ) strict, without rowid;

    CREATE INDEX IF NOT EXISTS a_key_idx ON zvpairs (a_key);
    CREATE INDEX IF NOT EXISTS b_key_idx ON zvpairs (b_key);
    CREATE INDEX IF NOT EXISTS uname_idx ON zvpairs (uname);
    CREATE INDEX IF NOT EXISTS mtime_idx ON zvpairs (mtime);
  SQL

  ###

  include Crorm::Model
  schema "zvpairs", :sqlite

  field dname : String, pkey: true
  field a_key : String, pkey: true
  field b_key : String, pkey: true

  field a_vstr : String
  field a_attr : String? = nil

  field b_vstr : String? = nil
  field b_attr : String? = nil

  field uname : String = ""
  field mtime : Int32 = 0
  field _flag : Int32 = 0

  def initialize(@dname, @a_key, @b_key, @a_vstr, @a_attr, @b_vstr, @b_attr)
  end

  def self.new(dname : String, cols : Array(String))
    new(
      dname: dname,
      a_key: cols[0],
      b_key: cols[1],
      a_vstr: cols[2],
      a_attr: cols[3]?.try { |x| x.empty? ? nil : x },
      b_vstr: cols[4]?.try { |x| x.empty? ? nil : x },
      b_attr: cols[5]?.try { |x| x.empty? ? nil : x },
    )
  end

  FETCH_SQL = <<-SQL
    select * from zvpairs where dname = $1 and _flag >= 0
    SQL

  def self.fetch_each(dname : String, &)
    SqPair.db.open_ro do |db|
      db.query_each(FETCH_SQL, dname) do |rs|
        yield rs.read(self)
      end
    end
  end

  def self.fetch_page(dname : String? = nil,
                      a_key : String? = nil,
                      b_key : String? = nil,
                      uname : String? = nil,
                      limit = 50, offset = 0)
    args = [] of String | Int32

    where_stmt = String.build do |sql|
      sql << " where 1 = 1"

      if dname
        args << dname.strip
        sql << " and dname = $" << args.size
      end

      if a_key
        args << ZvUtil.fix_query_str(a_key)
        sql << " and a_key like $" << args.size
      end

      if b_key
        args << ZvUtil.fix_query_str(b_key)
        sql << " and b_key like $" << args.size
      end

      if uname
        args << uname
        sql << " and uname = $" << args.size
      end

      sql << " order by mtime desc"

      args << limit
      sql << " limit $" << args.size

      args << offset
      sql << " offset $" << args.size
    end

    self.db.open_ro do |db|
      terms = db.query_all("select * from zvpairs #{where_stmt}", args: args, as: self)

      if terms.size < args[-2].as(Int32)
        count = terms.size
      else
        args[-2] = args[-2].as(Int32) &* 3
        count = db.query_all("select mtime from zvpairs #{where_stmt}", args: args, as: Int32).size
      end

      {terms, count &+ args[-1].as(Int32)}
    end
  end

  def self.find(dname : String, a_key : String, b_key : String)
    query = @@schema.select_by_pkey + " limit 1"
    self.db.query_one?(query, dname, a_key, b_key, as: self)
  end
end
