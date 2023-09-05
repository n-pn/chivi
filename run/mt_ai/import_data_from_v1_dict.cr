require "../../src/_util/char_util"
require "../../src/_util/viet_util"
require "../../src/mt_ai/data/mt_defn"

INP_PATH = "/2tb/app.chivi/var/mtapp/v1dic/v1_defns.dic"

struct Input
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter dic : Int32 = 0
  getter tab : Int32 = 0

  getter key : String = ""
  getter val : String = ""

  getter ptag : String = ""

  getter uname : String = ""
  getter mtime : Int64 = 0

  SPLIT = 'ǀ'

  def to_term(_lock = 1)
    zstr = CharUtil.to_canon(@key, true)
    vstr = VietUtil.fix_tones(val.split(SPLIT).first.strip)
    cpos, pecs = map_tag(@ptag)

    MT::MtDefn.new(
      zstr: zstr,
      cpos: cpos,
      vstr: vstr,
      pecs: pecs.to_s.gsub(" | ", " "),
      uname: @uname,
      mtime: @mtime,
      _lock: _lock,
      _flag: @tab == 1 ? 1 : 0
    )
  end

  MAP = {
    "Na"       => {"NR", MT::MtPecs[Nloc]},
    "Nag"      => {"NR", MT::MtPecs[Nloc]},
    "Nal"      => {"NR", MT::MtPecs[Nloc]},
    "Nl"       => {"NR", MT::MtPecs[None]},
    "Nr"       => {"NR", MT::MtPecs[Nper]},
    "Nrf"      => {"NR", MT::MtPecs[Nper]},
    "Nw"       => {"NR", MT::MtPecs[None]},
    "Nz"       => {"NR", MT::MtPecs[None]},
    "[\"vi\"]" => {"VV", MT::MtPecs[Vint]},
    "a"        => {"VA", MT::MtPecs[None]},
    "ab"       => {"JJ", MT::MtPecs[None]},
    "ad"       => {"VA", MT::MtPecs[None]},
    "ag"       => {"VA", MT::MtPecs[Sufx]},
    "al"       => {"ADJP", MT::MtPecs[None]},
    "an"       => {"VA", MT::MtPecs[None]},
    "av"       => {"VA", MT::MtPecs[None]},
    "az"       => {"VP", MT::MtPecs[None]},
    "bl"       => {"ADJP", MT::MtPecs[None]},
    "c"        => {"CS", MT::MtPecs[None]},
    "cc"       => {"CC", MT::MtPecs[None]},
    "d"        => {"AD", MT::MtPecs[None]},
    "dp"       => {"AD", MT::MtPecs[None]},
    "e"        => {"IJ", MT::MtPecs[None]},
    "h"        => {"_", MT::MtPecs[None]},
    "i"        => {"VP", MT::MtPecs[None]},
    "il"       => {"IP", MT::MtPecs[None]},
    "k"        => {"NN", MT::MtPecs[Sufx]},
    "ka"       => {"VA", MT::MtPecs[Sufx]},
    "kn"       => {"NN", MT::MtPecs[Sufx]},
    "kv"       => {"VV", MT::MtPecs[Sufx]},
    "m"        => {"CD", MT::MtPecs[None]},
    "mq"       => {"QP", MT::MtPecs[None]},
    "mqx"      => {"QP", MT::MtPecs[None]},
    "n"        => {"NN", MT::MtPecs[None]},
    "na"       => {"NN", MT::MtPecs[Ndes]},
    "nc"       => {"NN", MT::MtPecs[None]},
    "nf"       => {"NN", MT::MtPecs[Nloc, Sufx]},
    "ng"       => {"NN", MT::MtPecs[Sufx]},
    "nh"       => {"NN", MT::MtPecs[Nper, Sufx]},
    "nj"       => {"NN", MT::MtPecs[None]},
    "nl"       => {"NP", MT::MtPecs[None]},
    "nn"       => {"NN", MT::MtPecs[None]},
    "no"       => {"NN", MT::MtPecs[None]},
    "np"       => {"NP", MT::MtPecs[None]},
    "nr"       => {"NR", MT::MtPecs[None]},
    "nr 3"     => {"NR", MT::MtPecs[None]},
    "nr 4"     => {"NR", MT::MtPecs[None]},
    "ns"       => {"NN", MT::MtPecs[Nloc, Ndes]},
    "nt"       => {"NT", MT::MtPecs[None]},
    "nv"       => {"NN", MT::MtPecs[None]},
    "nz"       => {"NN", MT::MtPecs[None]},
    "p"        => {"P", MT::MtPecs[None]},
    "pba"      => {"P", MT::MtPecs[None]},
    "pbei"     => {"SB", MT::MtPecs[None]},
    "pp"       => {"P", MT::MtPecs[None]},
    "q"        => {"M", MT::MtPecs[None]},
    "qt"       => {"M", MT::MtPecs[None]},
    "qv"       => {"M", MT::MtPecs[None]},
    "qx"       => {"M", MT::MtPecs[None]},
    "r"        => {"PN", MT::MtPecs[None]},
    "rr"       => {"PN", MT::MtPecs[Nper, Pn_p]},
    "ry"       => {"PN", MT::MtPecs[Pn_d]},
    "rz"       => {"PN", MT::MtPecs[Pn_i]},
    "u"        => {"MSR", MT::MtPecs[None]},
    "ude1"     => {"DEG", MT::MtPecs[None]},
    "ude2"     => {"DEV", MT::MtPecs[None]},
    "ude3"     => {"DER", MT::MtPecs[None]},
    "udeng"    => {"ETC", MT::MtPecs[None]},
    "udh"      => {"SP", MT::MtPecs[None]},
    "uguo"     => {"AS", MT::MtPecs[None]},
    "ule"      => {"AS", MT::MtPecs[None]},
    "ulian"    => {"AD", MT::MtPecs[None]},
    "uls"      => {"CS", MT::MtPecs[None]},
    "usuo"     => {"MSR", MT::MtPecs[None]},
    "uyy"      => {"VA", MT::MtPecs[None]},
    "uzhe"     => {"AS", MT::MtPecs[None]},
    "uzhi"     => {"DEG", MT::MtPecs[None]},
    "v"        => {"VV", MT::MtPecs[None]},
    "vc"       => {"VV", MT::MtPecs[None]},
    "vd"       => {"VV", MT::MtPecs[None]},
    "vf"       => {"VV", MT::MtPecs[None]},
    "vg"       => {"VV", MT::MtPecs[Sufx]},
    "vi"       => {"VV", MT::MtPecs[Vint]},
    "vj"       => {"VV", MT::MtPecs[Vint]},
    "vl"       => {"VP", MT::MtPecs[None]},
    "vm"       => {"VV", MT::MtPecs[Vmod]},
    "vn"       => {"VV", MT::MtPecs[None]},
    "vo"       => {"VV", MT::MtPecs[None]},
    "vp"       => {"VP", MT::MtPecs[None]},
    "vshi"     => {"VC", MT::MtPecs[None]},
    "vx"       => {"VV", MT::MtPecs[None]},
    "vyou"     => {"VE", MT::MtPecs[None]},
    "w"        => {"PU", MT::MtPecs[None]},
    "x"        => {"FW", MT::MtPecs[None]},
    "xe"       => {"IJ", MT::MtPecs[None]},
    "xl"       => {"URL", MT::MtPecs[None]},
    "xo"       => {"ON", MT::MtPecs[None]},
    "xq"       => {"IP", MT::MtPecs[None]},
    "xt"       => {"IP", MT::MtPecs[None]},
    "xx"       => {"EM", MT::MtPecs[None]},
    "xy"       => {"ON", MT::MtPecs[None]},
    "y"        => {"ON", MT::MtPecs[None]},
    "~al"      => {"VP", MT::MtPecs[None]},
    "~ap"      => {"VP", MT::MtPecs[None]},
    "~dp"      => {"DNP", MT::MtPecs[None]},
    "~dv"      => {"VP", MT::MtPecs[None]},
    "~na"      => {"IP", MT::MtPecs[None]},
    "~nl"      => {"NP", MT::MtPecs[None]},
    "~np"      => {"NP", MT::MtPecs[None]},
    "~pn"      => {"PP", MT::MtPecs[None]},
    "~pp"      => {"PP", MT::MtPecs[None]},
    "~sa"      => {"IP", MT::MtPecs[None]},
    "~sv"      => {"IP", MT::MtPecs[None]},
    "~vl"      => {"VP", MT::MtPecs[None]},
    "~vp"      => {"VP", MT::MtPecs[None]},
  }

  def map_tag(ptag : String)
    MAP[ptag] ||= {"_", MT::MtPecs::None}
  end
end

inputs = DB.open("sqlite3:#{INP_PATH}?immutable=1") do |db|
  db.query_all("select * from defns where _flag >= 0 and val <> '' order by mtime asc", as: Input)
end

inputs = inputs.group_by(&.dic)

inputs.each do |d_id, entries|
  MT::MtDefn.db("book/#{d_id}").open_tx do |db|
    entries.each(&.to_term.upsert!(db: db))
  end

  puts "#{d_id}: #{entries.size} saved!"
rescue ex
  puts d_id, ex
end
