require "crorm"

require "./shared/*"
require "./zv_term"

struct MT::MtData
  class_getter init_sql = <<-SQL
    create table mtdata(
      d_id int not null,
      epos int not null,
      zstr text not null,

      vstr text not null default '',
      attr int not null default 0,

      dnum int not null default 0,
      prio int not null default 0,
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
  field epos : MtEpos, pkey: true, converter: SQ3Enum(MT::MtEpos)
  field zstr : String, pkey: true

  field vstr : String
  field attr : MtAttr, converter: SQ3Enum(MT::MtAttr)
  field dnum : DictEnum, converter: SQ3Enum(MT::DictEnum)
  field fpos : MtEpos = MT::MtEpos::X, converter: SQ3Enum(MT::MtEpos)

  def initialize(zterm : ZvTerm)
    @d_id = zterm.d_id
    @epos = @fpos = MtEpos.parse(zterm.cpos)

    @zstr = zterm.zstr
    @vstr = zterm.vstr

    @attr = MtAttr.parse_list(zterm.attr)
    @fpos = MtEpos.parse(zterm.fixp) unless zterm.fixp.empty?

    @dnum = DictEnum.from(zterm.d_id, zterm.plock)
  end

  def initialize(@d_id, @epos, @zstr,
                 @vstr = TextUtil.normalize(zstr),
                 @attr = :none, @dnum = :unknown_0)
  end

  def save!
    db = self.class.load_db(@d_id)
    spawn File.open(db.db_path.sub(".db3", ".log"), "a", &.puts(self.to_json))
    self.upsert!(db: db)
  end

  def to_mt
    MtTerm.new(vstr: @vstr, attr: @attr, dnum: @dnum)
  end

  def self.fetch(d_id : Int32)
    self.load_db(d_id).open_ro do |db|
      db.query_each("select * from #{@@schema.table} where d_id = $1", d_id) do |rs|
        yield rs.read(self)
      end
    end
  end

  def self.delete(d_id : Int32, epos : MtEpos, zstr : String)
    self.load_db(d_id).open_rw do |db|
      query = "delete from #{@@schema.table} where d_id = $1, epos = $2, zstr = $3"
      db.exec query, d_id, epos.to_i, zstr
    end
  end
end
