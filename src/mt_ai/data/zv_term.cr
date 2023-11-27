require "crorm"

require "../../_util/char_util"
require "../../_util/viet_util"

require "./mt_term"
require "./zv_util"

class MT::ZvTerm
  class_getter init_sql = <<-SQL
    create table zvterms(
      d_id int not null default 0,
      ipos int not null default 0,
      zstr text not null,
      --
      cpos text not null default 'X',
      vstr text not null default '',
      attr text not null default '',
      --
      segs text not null default '',
      ners text not null default '',
      tokr int not null default 2,
      posr int not null default 2,
      --
      uname text not null default '',
      mtime int not null default 0,
      plock int not null default 1,
      --
      primary key (d_id, ipos, zstr)
    ) strict, without rowid;
    SQL

  DIR = ENV.fetch("MT_DIR", "var/mt_db")

  def self.db_path(name : String, type : String = "db3")
    "#{DIR}/#{name}-term.#{type}"
  end

  ###

  include Crorm::Model
  schema "zvterms", :sqlite, multi: true, strict: false

  field d_id : Int32 = 0, pkey: true
  field zstr : String, pkey: true

  field ipos : Int32 = 0, pkey: true
  field cpos : String = "X"

  field vstr : String = ""
  field attr : String = ""

  field segs : String = ""
  field ners : String = ""

  field tokr : Int32 = 2
  field posr : Int32 = 2

  field uname : String = ""
  field mtime : Int32 = 0
  field plock : Int32 = 1

  def self.new(cols : Array(String), d_id = 0)
    zstr, cpos, vstr = cols

    zstr = CharUtil.to_canon(zstr, true)
    vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)

    new(zstr: zstr, d_id: d_id, cpos: cpos, vstr: vstr, attr: cols[3]? || "")
  end

  def self.new(zstr : String, cpos : String, vstr : String, attr : MtAttr, d_id : Int32 = 0)
    zstr = CharUtil.to_canon(zstr, true)
    vstr = VietUtil.fix_tones(vstr)
    new(zstr: zstr, d_id: d_id, cpos: cpos, vstr: vstr, attr: attr.to_str)
  end

  def initialize(@d_id, @zstr, @cpos,
                 @vstr = "", @attr = "",
                 @segs = "", @ners = "",
                 @tokr = 2, @posr = 2,
                 @uname = "", @mtime = 0,
                 @plock = 1)
    @ipos = MtEpos.parse(cpos).to_i
    @segs = zstr.size.to_s if @segs.empty?
  end

  # def ipos=(cpos : MtEpos)
  #   @cpos = cpos.to_s
  #   @ipos = cpos.to_i
  # end

  # def ipos=(@cpos : String)
  #   @ipos = MtEpos.parse(cpos).to_i
  # end

  def cpos=(cpos : MtEpos)
    @cpos = cpos.to_s
    @ipos = cpos.to_i
  end

  def cpos=(@cpos : String)
    @ipos = MtEpos.parse(cpos).to_i
  end

  def attr=(attr : MtAttr)
    @attr = attr.to_str
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "d_id", @d_id
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr

      jb.field "segs", @segs
      jb.field "ners", @ners

      jb.field "tokr", @tokr
      jb.field "posr", @posr

      jb.field "uname", @uname
      jb.field "mtime", ZvUtil.utime(@mtime)
      jb.field "plock", @plock
    end
  end

  def to_tsv_line
    String.build do |io|
      io << @zstr << '\t' << @cpos << '\t' << @vstr

      if @plock != 1
        io << '\t' << @attr
        io << '\t' << @uname << '\t' << @mtime
        io << '\t' << @plock
      elsif @uname != ""
        io << '\t' << @attr
        io << '\t' << @uname << '\t' << @mtime
      elsif @attr != ""
        io << '\t' << @attr
      end
    end
  end

  ###

  def self.find(dict : String, d_id : Int32, zstr : String, cpos : String)
    self.find(dict, d_id, zstr, ipos: MtEpos.parse(cpos).to_i)
  end

  def self.find(dict : String, d_id : Int32, zstr : String, ipos : Int32)
    query = @@schema.select_by_pkey + " limit 1"
    self.db(dict).query_one?(query, d_id, zstr, ipos, as: self)
  end

  def self.delete(dict : String, d_id : Int32, zstr : String, cpos : String)
    self.delete(dict, d_id, zstr, ipos: MtEpos.parse(cpos).to_i)
  end

  def self.delete(dict : String, d_id : Int32, zstr : String, ipos : Int32)
    self.db(dict).open_rw do |db|
      query = "delete from #{@@schema.table} where d_id = $1 and zstr = $2 and ipos = $3"
      db.exec query, d_id, zstr, ipos
    end
  end

  DB_NAMES = {"system", "common", "wn_all", "up_all", "qt_all", "pd_all"}
  DB_CACHE = {} of Int32 => Crorm::SQ3

  def self.load_db(type : Int32)
    DB_CACHE[type] ||= self.db(DB_NAMES[type])
  end
end
