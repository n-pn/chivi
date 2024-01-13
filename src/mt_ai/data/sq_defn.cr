require "crorm"

require "../enum/*"
require "./pg_term"

# convert from postgresql database for faster loading
struct MT::SqDefn
  class_getter init_sql = <<-SQL
    create table mtdata(
      d_id int not null,
      epos int not null,
      zstr text not null,

      vstr text not null default '',
      attr int not null default 0,

      dnum int not null default 0,
      fpos int not null default 0,

      primary key (d_id, epos, zstr)
    ) strict, without rowid;
    SQL

  DIR = ENV["MT_DIR"]? || "var/mtdic/mdata"

  def self.db_path(d_id : Int32)
    "#{DIR}/#{d_id % 10}.db3"
  end

  DB_CACHE = {} of Int32 => Crorm::SQ3

  def self.load_db(d_id : Int32)
    DB_CACHE[d_id % 10] ||= self.db(d_id)
  end

  ###

  include Crorm::Model
  schema "mtdata", :sqlite, multi: true, strict: false

  field d_id : Int32, pkey: true
  field epos : Int32, pkey: true
  field zstr : String, pkey: true

  field vstr : String
  field attr : Int32

  field dnum : Int32
  field fpos : Int32 = 0

  def initialize(zterm : ZvTerm)
    @d_id = zterm.d_id
    @epos = @fpos = MtEpos.parse(zterm.cpos).to_i

    @zstr = zterm.zstr
    @vstr = zterm.vstr

    @attr = MtAttr.parse_list(zterm.attr).to_i
    @fpos = MtEpos.parse(zterm.fixp).to_i unless zterm.fixp.empty?

    dtype = zterm.d_id % 10 < 4 ? 2_i8 : 1_i8
    plock = zterm.plock.to_i8 > 0 ? 1_i8 : 0_i8
    @dnum = Dnum.from(zterm.d_id, zterm.plock)
  end

  def initialize(@d_id, @epos, @zstr,
                 @vstr = TextUtil.normalize(zstr),
                 @attr = :none, @dnum = :unknown_0)
  end

  def self.query_each(d_id : Int32, & : (String, MtEpos, ZvDefn) ->)
    load_db(d_id).open_ro do |db|
      query = "select zstr, epos, vstr, attr, dnum, fpos from mtdata where d_id = $1"

      db.query_each(query, d_id) do |rs|
        zstr = rs.read(String)
        epos = MtEpos.from_value(rs.read(Int32))

        vstr = rs.read(String)
        attr = MtAttr.from_value(rs.read(Int32))
        dnum = MtDnum.from_value(rs.read(Int32))
        fpos = MtEpos.from_value(rs.read(Int32))

        defn = ZvDefn.new(vstr: vstr, attr: attr, dnum: dnum, fpos: fpos)

        yield zstr, epos, defn
      end
    end
  end

  # def save!
  #   db = self.class.load_db(@d_id)
  #   spawn File.open(db.db_path.sub(".db3", ".log"), "a", &.puts(self.to_json))
  #   self.upsert!(db: db)
  # end

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
end
