require "sqlite3"
require "../../../src/mt_ai/data/zv_defn"

struct Input
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter dic : Int32 = 0
  getter tab : Int32 = 0

  getter key : String = ""
  getter val : String = ""

  getter ptag : String = ""

  # getter uname : String = ""
  getter mtime : Int32 = 0

  MAP = {
    "Na"       => {"NR", MT::MtAttr[Nloc]},
    "Nag"      => {"NR", MT::MtAttr[Nloc]},
    "Nal"      => {"NR", MT::MtAttr[Nloc]},
    "Nl"       => {"NR", MT::MtAttr[Ndes]},
    "Nr"       => {"NR", MT::MtAttr[Nper]},
    "Nrf"      => {"NR", MT::MtAttr[Nper]},
    "Nw"       => {"NR", MT::MtAttr[None]},
    "Nz"       => {"NR", MT::MtAttr[None]},
    "[\"vi\"]" => {"VV", MT::MtAttr[Vint]},
    "a"        => {"VA", MT::MtAttr[None]},
    "ab"       => {"JJ", MT::MtAttr[None]},
    "ad"       => {"VA", MT::MtAttr[None]},
    "ag"       => {"VA", MT::MtAttr[Sufx]},
    "al"       => {"ADJP", MT::MtAttr[None]},
    "an"       => {"VA", MT::MtAttr[None]},
    "av"       => {"VA", MT::MtAttr[None]},
    "az"       => {"VP", MT::MtAttr[None]},
    "bl"       => {"ADJP", MT::MtAttr[None]},
    "c"        => {"CS", MT::MtAttr[None]},
    "cc"       => {"CC", MT::MtAttr[None]},
    "d"        => {"AD", MT::MtAttr[None]},
    "dp"       => {"ADVP", MT::MtAttr[None]},
    "e"        => {"IJ", MT::MtAttr[None]},
    "h"        => {"_", MT::MtAttr[None]},
    "i"        => {"VP", MT::MtAttr[None]},
    "il"       => {"IP", MT::MtAttr[None]},
    "k"        => {"NN", MT::MtAttr[Sufx]},
    "ka"       => {"VA", MT::MtAttr[Sufx]},
    "kn"       => {"NN", MT::MtAttr[Sufx]},
    "kv"       => {"VV", MT::MtAttr[Sufx]},
    "m"        => {"CD", MT::MtAttr[None]},
    "mq"       => {"QP", MT::MtAttr[None]},
    "mqx"      => {"QP", MT::MtAttr[None]},
    "n"        => {"NN", MT::MtAttr[None]},
    "na"       => {"NN", MT::MtAttr[Ndes]},
    "nc"       => {"NN", MT::MtAttr[None]},
    "nf"       => {"NN", MT::MtAttr[Nloc, Sufx]},
    "ng"       => {"NN", MT::MtAttr[Sufx]},
    "nh"       => {"NN", MT::MtAttr[Nper, Sufx]},
    "nj"       => {"NN", MT::MtAttr[None]},
    "nl"       => {"NP", MT::MtAttr[None]},
    "nn"       => {"NN", MT::MtAttr[None]},
    "no"       => {"NN", MT::MtAttr[None]},
    "np"       => {"NP", MT::MtAttr[None]},
    "nr"       => {"NR", MT::MtAttr[Nper]},
    "nr 3"     => {"NR", MT::MtAttr[Nper]},
    "nr 4"     => {"NR", MT::MtAttr[Nper]},
    "ns"       => {"NN", MT::MtAttr[Nloc, Ndes]},
    "nt"       => {"NT", MT::MtAttr[Ntmp]},
    "nv"       => {"NN", MT::MtAttr[None]},
    "nz"       => {"NN", MT::MtAttr[None]},
    "p"        => {"P", MT::MtAttr[None]},
    "pba"      => {"P", MT::MtAttr[None]},
    "pbei"     => {"SB", MT::MtAttr[None]},
    "pp"       => {"P", MT::MtAttr[None]},
    "q"        => {"M", MT::MtAttr[None]},
    "qt"       => {"M", MT::MtAttr[None]},
    "qv"       => {"M", MT::MtAttr[None]},
    "qx"       => {"M", MT::MtAttr[None]},
    "r"        => {"PN", MT::MtAttr[None]},
    "rr"       => {"PN", MT::MtAttr[Nper]},
    "ry"       => {"PN", MT::MtAttr[Pn_d]},
    "rz"       => {"PN", MT::MtAttr[Pn_i]},
    "u"        => {"MSP", MT::MtAttr[None]},
    "ude1"     => {"DEG", MT::MtAttr[None]},
    "ude2"     => {"DEV", MT::MtAttr[None]},
    "ude3"     => {"DER", MT::MtAttr[None]},
    "udeng"    => {"ETC", MT::MtAttr[None]},
    "udh"      => {"SP", MT::MtAttr[None]},
    "uguo"     => {"AS", MT::MtAttr[None]},
    "ule"      => {"AS", MT::MtAttr[None]},
    "ulian"    => {"AD", MT::MtAttr[None]},
    "uls"      => {"CS", MT::MtAttr[None]},
    "usuo"     => {"MSP", MT::MtAttr[None]},
    "uyy"      => {"VA", MT::MtAttr[None]},
    "uzhe"     => {"AS", MT::MtAttr[None]},
    "uzhi"     => {"DEG", MT::MtAttr[None]},
    "v"        => {"VV", MT::MtAttr[None]},
    "vc"       => {"VV", MT::MtAttr[None]},
    "vd"       => {"VV", MT::MtAttr[None]},
    "vf"       => {"VV", MT::MtAttr[None]},
    "vg"       => {"VV", MT::MtAttr[Sufx]},
    "vi"       => {"VV", MT::MtAttr[Vint]},
    "vj"       => {"VV", MT::MtAttr[Vint]},
    "vl"       => {"VP", MT::MtAttr[None]},
    "vm"       => {"VV", MT::MtAttr[Vmod]},
    "vn"       => {"VV", MT::MtAttr[None]},
    "vo"       => {"VV", MT::MtAttr[None]},
    "vp"       => {"VP", MT::MtAttr[None]},
    "vshi"     => {"VC", MT::MtAttr[None]},
    "vx"       => {"VV", MT::MtAttr[None]},
    "vyou"     => {"VE", MT::MtAttr[None]},
    "w"        => {"PU", MT::MtAttr[None]},
    "x"        => {"FW", MT::MtAttr[None]},
    "xe"       => {"IJ", MT::MtAttr[None]},
    "xl"       => {"URL", MT::MtAttr[Asis]},
    "xo"       => {"ON", MT::MtAttr[None]},
    "xq"       => {"IP", MT::MtAttr[None]},
    "xt"       => {"IP", MT::MtAttr[None]},
    "xx"       => {"EM", MT::MtAttr[Asis]},
    "xy"       => {"ON", MT::MtAttr[None]},
    "y"        => {"ON", MT::MtAttr[None]},
    "~al"      => {"VP", MT::MtAttr[None]},
    "~ap"      => {"VP", MT::MtAttr[None]},
    "~dp"      => {"DNP", MT::MtAttr[None]},
    "~dv"      => {"VP", MT::MtAttr[None]},
    "~na"      => {"IP", MT::MtAttr[None]},
    "~nl"      => {"NP", MT::MtAttr[None]},
    "~np"      => {"NP", MT::MtAttr[None]},
    "~pn"      => {"PP", MT::MtAttr[None]},
    "~pp"      => {"PP", MT::MtAttr[None]},
    "~sa"      => {"IP", MT::MtAttr[None]},
    "~sv"      => {"IP", MT::MtAttr[None]},
    "~vl"      => {"VP", MT::MtAttr[None]},
    "~vp"      => {"VP", MT::MtAttr[None]},
  }

  def map_tag(ptag : String)
    MAP[ptag] ||= {"X", MT::MtAttr::None}
  end

  SPLIT = 'ǀ'

  def to_tsv(io : IO)
    cpos, attr = map_tag(@ptag)
    vstr = @val.split(SPLIT).first.strip
    {@key, cpos, vstr, attr}.join(io, '\t')
  end
end

INP_PATH = "/2tb/app.chivi/var/mtapp/v1dic/v1_defns.dic"
inputs = DB.open("sqlite3:#{INP_PATH}?immutable=1") do |db|
  query = "select * from defns where dic > -2 and prio > 0 and _flag >= 0 and val <> '' order by mtime desc"
  db.query_all(query, as: Input)
end

OUT_DIR = "var/mtdic/mt_v1"
Dir.mkdir_p(OUT_DIR)

File.delete?("#{OUT_DIR}/regular.tsv")
File.delete?("#{OUT_DIR}/combine.tsv")

inputs.group_by(&.dic).each do |d_id, terms|
  dname = d_id < 0 ? "regular" : "combine"
  dpath = "#{OUT_DIR}/#{dname}.tsv"
  terms.uniq!(&.key).sort!(&.mtime)

  File.open(dpath, "a") do |file|
    terms.each do |term|
      term.to_tsv(file)
      file.puts
    end
  end

  puts "#{dpath}: #{terms.size} saved!"
end
