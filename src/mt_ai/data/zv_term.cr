require "crorm"

require "../../_util/char_util"
require "../../_util/viet_util"

require "./mt_term"
require "./zv_util"

class MT::ZvTerm
  class_getter init_sql = <<-SQL
    create table zvterms(
      d_id int not null default 0,

      cpos text not null default 'X',
      ipos int not null default 0,

      zstr text not null,
      vstr text not null default '',

      attr text not null default '',
      iatt int not null default 0,

      uname text not null default '',
      mtime int not null default 0,
      plock int not null default 1,

      primary key (d_id, ipos, zstr)
    ) strict, without rowid;
    SQL

  DIR = ENV["MT_DIR"]? || "var/mt_db"

  def self.db_path(name : String, type : String = "db3")
    "#{DIR}/#{name}.#{type}"
  end

  ###

  include Crorm::Model
  schema "zvterms", :sqlite, multi: true

  field d_id : Int32 = 0, pkey: true
  field ipos : Int32 = 0, pkey: true
  field zstr : String, pkey: true

  field cpos : String = "X"
  field vstr : String = ""

  field attr : String = ""
  field iatt : Int32 = 0

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

  def initialize(@zstr, @d_id = 0, @cpos = "X", @vstr = "", @attr = "",
                 @uname = "", @mtime = 0, @plock = 1)
    @ipos = MtEpos.parse(cpos).to_i
    @iatt = MtAttr.parse_list(attr).to_i
  end

  def ipos=(cpos : MtEpos)
    @cpos = cpos.to_s
    @ipos = cpos.to_i
  end

  def ipos=(@cpos : String)
    @ipos = MtEpos.parse(cpos).to_i
  end

  def cpos=(cpos : MtEpos)
    @cpos = cpos.to_s
    @ipos = cpos.to_i
  end

  def cpos=(@cpos : String)
    @ipos = MtEpos.parse(cpos).to_i
  end

  def attr=(attr : MtAttr)
    @attr = attr.to_str
    @iatt = attr.to_i
  end

  def attr=(@attr : String)
    @iatt = MtAttr.parse_list(attr).to_i
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr

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

  def self.find(dict : String, zstr : String, cpos : String)
    self.find(dict, zstr, ipos: MtEpos.parse(cpos).to_i)
  end

  def self.find(dict : String, zstr : String, ipos : Int32)
    query = @@schema.select_by_pkey + " limit 1"
    self.db(dict).query_one?(query, zstr, ipos, as: self)
  end

  def self.delete(dict : String, zstr : String, cpos : String)
    self.delete(dict, zstr, ipos: MtEpos.parse(cpos).to_i)
  end

  def self.delete(dict : String, zstr : String, ipos : Int32)
    self.db(dict).open_rw do |db|
      query = "delete from #{@@schema.table} where zstr = $1, ipos = $2"
      db.exec query, zstr, ipos
    end
  end
end
