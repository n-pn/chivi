require "crorm"
require "../base/*"
require "./pg_defn"

# convert from postgresql database for faster loading
struct MT::SqDefn
  class_getter init_sql = <<-SQL
    create table zvdefn(
      d_id int not null,
      epos int not null,
      zstr text not null,

      vstr text not null default '',
      attr int not null default 0,

      dnum int not null default 0,
      rank int not null default 0,

      primary key (d_id, epos, zstr)
    ) strict, without rowid;
    SQL

  def self.db_path(d_id : Int32)
    "/srv/chivi/mt_db/mdata/#{d_id % 10}.db3"
  end

  DB_CACHE = {} of Int32 => Crorm::SQ3

  def self.load_db(d_id : Int32)
    DB_CACHE[d_id % 10] ||= self.db(d_id)
  end

  ###

  include Crorm::Model
  schema "zvdefn", :sqlite, multi: true, strict: false

  field d_id : Int32, pkey: true
  field epos : Int32, pkey: true
  field zstr : String, pkey: true

  field vstr : String
  field attr : Int32
  field rank : Int32 = 0

  field dnum : Int32 = 0

  def initialize(@d_id, @epos, @zstr, @vstr,
                 @attr = 0, @dnum = 0, @rank = 0)
  end

  def initialize(zterm : PgDefn)
    @d_id = zterm.d_id
    @epos = MtEpos.parse(zterm.cpos).to_i
    @zstr = zterm.zstr

    @vstr = zterm.vstr
    @attr = MtAttr.parse_list(zterm.attr).to_i

    @dnum = zterm.plock < 0 ? -1 : MtDnum.from(@d_id, zterm.plock).to_i
    @rank = zterm.rank.to_i
  end

  def save!(db = self.class.load_db(@d_id))
    self.upsert!(db: db)
  end

  def self.fetch(d_id : Int32, &)
    self.load_db(d_id).open_ro do |db|
      db.query_each("select * from #{@@schema.table} where d_id = $1", d_id) do |rs|
        yield rs.read(self)
      end
    end
  end

  def self.delete(d_id : Int32, epos : MtEpos, zstr : String)
    self.load_db(d_id).open_rw do |db|
      query = "delete from #{@@schema.table} where d_id = $1 and epos = $2 and zstr = $3"
      db.exec query, d_id, epos.to_i, zstr
    end
  end

  def self.query_each(d_id : Int32, & : (String, MtDefn) ->)
    load_db(d_id).open_ro do |db|
      query = "select zstr, vstr, epos, attr, dnum, rank from zvdefn where d_id = $1 and dnum >= 0"
      db.query_each(query, d_id) { |rs| yield rs.read(String), MtDefn.new(rs) }
    end
  end
end
