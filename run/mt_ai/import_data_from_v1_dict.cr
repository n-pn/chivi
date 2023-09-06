require "../../src/mt_ai/data/db_term"

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
  getter mtime : Int32 = 0

  SPLIT = 'ǀ'

  def to_term(privi = 1)
    vstr = @val.split(SPLIT).first.strip
    cpos, prop = map_tag(@ptag)

    term = MT::DbTerm.new(
      zstr: @key, cpos: cpos,
      vstr: vstr, prop: prop,
    )

    term.uname = @uname
    term.mtime = @mtime
    term.privi = @tab == 1 ? 1 : 0
    term._flag = @tab

    term
  end

  MAP = {
    "Na"       => {"NR", MT::MtProp[Nloc, Npos]},
    "Nag"      => {"NR", MT::MtProp[Nloc, Npos]},
    "Nal"      => {"NR", MT::MtProp[Nloc, Npos]},
    "Nl"       => {"NR", MT::MtProp[Ndes]},
    "Nr"       => {"NR", MT::MtProp[Nper, Npos]},
    "Nrf"      => {"NR", MT::MtProp[Nper, Npos]},
    "Nw"       => {"NR", MT::MtProp[Npos]},
    "Nz"       => {"NR", MT::MtProp[Npos]},
    "[\"vi\"]" => {"VV", MT::MtProp[Vint]},
    "a"        => {"VA", MT::MtProp[None]},
    "ab"       => {"JJ", MT::MtProp[None]},
    "ad"       => {"VA", MT::MtProp[None]},
    "ag"       => {"VA", MT::MtProp[Sufx]},
    "al"       => {"ADJP", MT::MtProp[None]},
    "an"       => {"VA", MT::MtProp[None]},
    "av"       => {"VA", MT::MtProp[None]},
    "az"       => {"VP", MT::MtProp[None]},
    "bl"       => {"ADJP", MT::MtProp[None]},
    "c"        => {"CS", MT::MtProp[None]},
    "cc"       => {"CC", MT::MtProp[None]},
    "d"        => {"AD", MT::MtProp[None]},
    "dp"       => {"ADVP", MT::MtProp[None]},
    "e"        => {"IJ", MT::MtProp[None]},
    "h"        => {"_", MT::MtProp[None]},
    "i"        => {"VP", MT::MtProp[None]},
    "il"       => {"IP", MT::MtProp[None]},
    "k"        => {"NN", MT::MtProp[Sufx]},
    "ka"       => {"VA", MT::MtProp[Sufx]},
    "kn"       => {"NN", MT::MtProp[Sufx]},
    "kv"       => {"VV", MT::MtProp[Sufx]},
    "m"        => {"CD", MT::MtProp[None]},
    "mq"       => {"QP", MT::MtProp[None]},
    "mqx"      => {"QP", MT::MtProp[None]},
    "n"        => {"NN", MT::MtProp[None]},
    "na"       => {"NN", MT::MtProp[Ndes]},
    "nc"       => {"NN", MT::MtProp[None]},
    "nf"       => {"NN", MT::MtProp[Nloc, Sufx]},
    "ng"       => {"NN", MT::MtProp[Sufx]},
    "nh"       => {"NN", MT::MtProp[Nper, Sufx]},
    "nj"       => {"NN", MT::MtProp[None]},
    "nl"       => {"NP", MT::MtProp[Npos]},
    "nn"       => {"NN", MT::MtProp[Npos]},
    "no"       => {"NN", MT::MtProp[Npos]},
    "np"       => {"NP", MT::MtProp[None]},
    "nr"       => {"NR", MT::MtProp[Nper, Npos]},
    "nr 3"     => {"NR", MT::MtProp[Nper, Npos]},
    "nr 4"     => {"NR", MT::MtProp[Nper, Npos]},
    "ns"       => {"NN", MT::MtProp[Nloc, Ndes]},
    "nt"       => {"NT", MT::MtProp[Ntmp]},
    "nv"       => {"NN", MT::MtProp[Npos]},
    "nz"       => {"NN", MT::MtProp[Npos]},
    "p"        => {"P", MT::MtProp[None]},
    "pba"      => {"P", MT::MtProp[None]},
    "pbei"     => {"SB", MT::MtProp[None]},
    "pp"       => {"P", MT::MtProp[None]},
    "q"        => {"M", MT::MtProp[None]},
    "qt"       => {"M", MT::MtProp[None]},
    "qv"       => {"M", MT::MtProp[None]},
    "qx"       => {"M", MT::MtProp[None]},
    "r"        => {"PN", MT::MtProp[None]},
    "rr"       => {"PN", MT::MtProp[Nper, Npos]},
    "ry"       => {"PN", MT::MtProp[Pn_d]},
    "rz"       => {"PN", MT::MtProp[Pn_i]},
    "u"        => {"MSP", MT::MtProp[None]},
    "ude1"     => {"DEG", MT::MtProp[None]},
    "ude2"     => {"DEV", MT::MtProp[None]},
    "ude3"     => {"DER", MT::MtProp[None]},
    "udeng"    => {"ETC", MT::MtProp[None]},
    "udh"      => {"SP", MT::MtProp[None]},
    "uguo"     => {"AS", MT::MtProp[None]},
    "ule"      => {"AS", MT::MtProp[None]},
    "ulian"    => {"AD", MT::MtProp[None]},
    "uls"      => {"CS", MT::MtProp[None]},
    "usuo"     => {"MSP", MT::MtProp[None]},
    "uyy"      => {"VA", MT::MtProp[None]},
    "uzhe"     => {"AS", MT::MtProp[None]},
    "uzhi"     => {"DEG", MT::MtProp[None]},
    "v"        => {"VV", MT::MtProp[None]},
    "vc"       => {"VV", MT::MtProp[None]},
    "vd"       => {"VV", MT::MtProp[None]},
    "vf"       => {"VV", MT::MtProp[None]},
    "vg"       => {"VV", MT::MtProp[Sufx]},
    "vi"       => {"VV", MT::MtProp[Vint]},
    "vj"       => {"VV", MT::MtProp[Vint]},
    "vl"       => {"VP", MT::MtProp[None]},
    "vm"       => {"VV", MT::MtProp[Vmod]},
    "vn"       => {"VV", MT::MtProp[None]},
    "vo"       => {"VV", MT::MtProp[None]},
    "vp"       => {"VP", MT::MtProp[None]},
    "vshi"     => {"VC", MT::MtProp[None]},
    "vx"       => {"VV", MT::MtProp[None]},
    "vyou"     => {"VE", MT::MtProp[None]},
    "w"        => {"PU", MT::MtProp[None]},
    "x"        => {"FW", MT::MtProp[None]},
    "xe"       => {"IJ", MT::MtProp[None]},
    "xl"       => {"URL", MT::MtProp[Asis]},
    "xo"       => {"ON", MT::MtProp[None]},
    "xq"       => {"IP", MT::MtProp[None]},
    "xt"       => {"IP", MT::MtProp[None]},
    "xx"       => {"EM", MT::MtProp[Asis]},
    "xy"       => {"ON", MT::MtProp[None]},
    "y"        => {"ON", MT::MtProp[None]},
    "~al"      => {"VP", MT::MtProp[None]},
    "~ap"      => {"VP", MT::MtProp[None]},
    "~dp"      => {"DNP", MT::MtProp[None]},
    "~dv"      => {"VP", MT::MtProp[None]},
    "~na"      => {"IP", MT::MtProp[None]},
    "~nl"      => {"NP", MT::MtProp[None]},
    "~np"      => {"NP", MT::MtProp[None]},
    "~pn"      => {"PP", MT::MtProp[None]},
    "~pp"      => {"PP", MT::MtProp[None]},
    "~sa"      => {"IP", MT::MtProp[None]},
    "~sv"      => {"IP", MT::MtProp[None]},
    "~vl"      => {"VP", MT::MtProp[None]},
    "~vp"      => {"VP", MT::MtProp[None]},
  }

  def map_tag(ptag : String)
    MAP[ptag] ||= {"_", MT::MtProp::None}
  end
end

inputs = DB.open("sqlite3:#{INP_PATH}?immutable=1") do |db|
  db.query_all("select * from defns where _flag >= 0 and val <> '' order by mtime asc", as: Input)
end

inputs = inputs.group_by(&.dic)

inputs.each do |d_id, entries|
  MT::DbTerm.db("book/#{d_id}").open_tx do |db|
    entries.each(&.to_term.upsert!(db: db))
  end

  puts "#{d_id}: #{entries.size} saved!"
rescue ex
  puts d_id, ex
end
