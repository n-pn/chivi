require "crorm"
require "../../_util/char_util"
require "../../_util/viet_util"

require "./mt_term"

class MT::ViTerm
  class_getter init_sql = <<-SQL
    create table terms(
      zstr varchar not null,
      cpos varchar not null default '_',

      vstr varchar not null default '',
      attr varchar not null default '',

      icpos smallint not null default 0,
      iattr int not null default 0,

      uname varchar not null default '',
      mtime bigint not null default 0,
      plock smallint not null default 0,

      _flag int not null default 0,

      primary key (zstr, cpos)
    )
    SQL

  DIR = "var/mtapp"

  def self.db_path(dname : String, type : String = "db3")
    "#{DIR}/mt_ai/#{dname}.#{type}"
  end

  ###

  include Crorm::Model
  schema "terms", :sqlite, multi: true

  field zstr : String, pkey: true
  field cpos : String, pkey: true

  field vstr : String = ""
  field attr : String = ""

  field uname : String = ""
  field mtime : Int32 = 0
  field plock : Int32 = 0

  field icpos : Int32 = 0
  field iattr : Int32 = 0

  field _flag : Int32 = 0

  def self.new(cols : Array(String))
    zstr, cpos, vstr = cols
    # raise "invalid #{cpos}" unless cpos.in?(MtCpos::ALL)

    zstr = CharUtil.to_canon(zstr, true)
    vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)

    attr = MT::MtAttr.parse_list!(cols[3]?)

    new(zstr: zstr, cpos: cpos, vstr: vstr, attr: attr.to_str)
  end

  def self.new(zstr : String, cpos : String, vstr : String, attr : MtAttr)
    zstr = CharUtil.to_canon(zstr, true)
    vstr = VietUtil.fix_tones(vstr)
    new(zstr: zstr, cpos: cpos, vstr: vstr, attr: attr.to_str)
  end

  def initialize(@zstr, @cpos = "_", @vstr = "", @attr = "",
                 @uname = "", @mtime = 0, @plock = 1)
    self.fix_enums!
  end

  def to_mt(dtype : MtDtyp = :primary)
    MtTerm.new(
      vstr: @vstr,
      attr: MtAttr.new(@iattr),
      dnum: MtDnum.from(dtype: dtype, plock: @plock.to_i8)
    )
  end

  def fix_enums!
    @icpos = MtCpos[@cpos].to_i
    @iattr = MtAttr.parse_list!(@attr).to_i
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr == "None" ? "" : @attr.sub("Npos", "").strip

      jb.field "uname", @uname
      jb.field "mtime", self.class.utime(@mtime)

      jb.field "plock", @plock
    end
  end

  def to_tsv_line
    String.build do |io|
      io << @zstr << '\t' << @cpos << '\t' << @vstr

      if @plock != 1
        io << '\t' << @attr.sub("Npos", "").strip
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

  all = self.db("regular").open_ro do |db|
    db.query_all "select zstr, cpos from terms", as: {String, String}
  end

  def self.find(dict : String, zstr : String, cpos : String)
    query = @@schema.select_by_pkey + " limit 1"
    self.db(dict).query_one?(query, zstr, cpos, as: self)
  end
end
