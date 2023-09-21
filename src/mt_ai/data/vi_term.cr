require "crorm"

require "../../_util/char_util"
require "../../_util/viet_util"
require "./mt_term"

class MT::ViTerm
  class_getter init_sql = <<-SQL
    create table terms(
      ipos tinyint not null default 0,
      cpos varchar not null default 'X',

      zstr varchar not null,
      vstr varchar not null default '',

      attr varchar not null default '',
      iatt integer not null default 0,

      uname varchar not null default '',
      mtime integer not null default 0,
      plock tinyint not null default 1,

      primary key (ipos, zstr)
    )
    SQL

  DIR = ENV["MT_DIR"]? || "var/mt_db/mt_ai"

  def self.db_path(dname : String, type : String = "db3")
    "#{DIR}/#{dname}.#{type}"
  end

  ###

  include Crorm::Model
  schema "terms", :sqlite, multi: true

  field zstr : String, pkey: true
  field vstr : String = ""

  field ipos : Int32, pkey: true
  field cpos : String = ""

  field attr : String = ""
  field iatt : Int32 = 0

  field uname : String = ""
  field mtime : Int32 = 0
  field plock : Int32 = 1

  def self.new(cols : Array(String))
    zstr, cpos, vstr = cols

    zstr = CharUtil.to_canon(zstr, true)
    vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)

    new(zstr: zstr, cpos: cpos, vstr: vstr, attr: cols[3]? || "")
  end

  def self.new(zstr : String, cpos : String, vstr : String, attr : MtAttr)
    zstr = CharUtil.to_canon(zstr, true)
    vstr = VietUtil.fix_tones(vstr)
    new(zstr: zstr, cpos: cpos, vstr: vstr, attr: attr.to_str)
  end

  def initialize(@zstr, @cpos = "X", @vstr = "", @attr = "",
                 @uname = "", @mtime = 0, @plock = 1)
    @ipos = MtEpos.parse(cpos).to_i
    @iatt = MtAttr.parse_list(attr).to_i
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr

      jb.field "uname", @uname
      jb.field "mtime", self.class.utime(@mtime)

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

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc)
    ((rtime.to_unix &- EPOCH) // 60).to_i
  end

  def self.utime(mtime : Int32)
    mtime > 0 ? EPOCH &+ mtime &* 60 : 0
  end

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
