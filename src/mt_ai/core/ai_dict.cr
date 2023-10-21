# require "../util/*"
require "../data/*"
require "./qt_core"
require "./tl_unit"

class MT::AiDict
  @main_dict : MtDict
  @auto_dict : MtDict

  @@cache = {} of String => self

  def self.load(pdict : String)
    @@cache[pdict] ||= new(pdict)
  end

  def initialize(@pdict : String = "combined")
    @main_dict = MtDict.load(pdict)
    @auto_dict = MtDict.new(pdict, :autogen)

    @dict_list = {@main_dict, MtDict.regular, @auto_dict}
  end

  def dsize
    {@main_dict.size, @auto_dict.size, MtDict.regular.size}
  end

  def get(zstr : String, epos : MtEpos) : MtTerm
    get?(zstr, epos) || init(zstr, epos)
  end

  def get?(zstr : String, epos : MtEpos)
    @dict_list.each do |dict|
      dict.get?(zstr, epos).try { |found| return found }
    end
  end

  def get_alt?(zstr : String)
    @dict_list.each do |dict|
      dict.any?(zstr).try { |found| return found }
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def init(zstr : String, epos : MtEpos) : MtTerm
    case epos
    when .pu?
      vstr = CharUtil.normalize(zstr)
      add_temp(zstr, epos, vstr, MtAttr.parse_punct(zstr))
    when .em?
      add_temp(zstr, epos, zstr, MtAttr[Asis, Capx])
    when .url?
      add_temp(zstr, epos, CharUtil.normalize(zstr), MtAttr[Asis])
    when .od?
      add_temp(zstr, epos, init_od(zstr), :none)
    when .cd?
      add_temp(zstr, epos, init_cd(zstr), :none)
    when .vv?
      get_alt?(zstr) || add_temp(zstr, epos, init_vv(zstr), :none)
    when .nt?
      vstr, attr = init_nt(zstr)
      add_temp(zstr, epos, vstr, attr)
    when .nr?
      get_alt?(zstr) || add_temp(zstr, epos, init_nr(zstr), :none)
    else
      get_alt?(zstr) || add_temp(zstr, epos, QtCore.tl_hvword(zstr), :none)
    end
  end

  @[AlwaysInline]
  def add_temp(zstr : String, epos : MtEpos, vstr : String, attr : MtAttr = :none)
    # TODO: Add to main_dict directly?
    @auto_dict.add(zstr, epos, vstr, attr)
  end

  NT_RE = /^([\d零〇一二两三四五六七八九十百千]+)(.*)/

  def init_nt(zstr : String)
    unless match = NT_RE.match(zstr)
      vstr = get_alt?(zstr).try(&.vstr) || QtCore.tl_hvname(zstr)
      return {vstr, MtAttr::Ntmp}
    end

    _, digits, suffix = match
    numstr = TlUnit.translate(digits)

    at_t = MtAttr[At_t, Ntmp]
    ntmp = MtAttr::Ntmp

    case suffix
    when "年"       then {"năm #{numstr}", ntmp}
    when "月"       then {"tháng #{numstr}", ntmp}
    when "日"       then {"ngày #{numstr}", ntmp}
    when "号"       then {"#{digits.size > 1 ? "ngày" : "mồng"} #{numstr}", ntmp}
    when "点", "时"  then {"#{numstr} giờ", at_t}
    when "分", "分钟" then {"#{numstr} phút", at_t}
    when "秒", "秒钟" then {"#{numstr} giây", at_t}
    when "半"       then {"#{numstr} rưỡi", at_t}
    else
      vstr = suffix.empty? ? numstr : "#{numstr} #{get(suffix, :NT).vstr}"
      {numstr, ntmp}
    end
  end

  def init_nr(zstr : String)
    # TODO: call special name translation engine

    fname, pchar, lname = zstr.partition(/\p{P}+/)
    return QtCore.tl_hvname(zstr) if pchar.empty?

    fname_vstr = get?(fname, :NR).try(&.vstr) || QtCore.tl_hvname(fname)
    lname_vstr = get?(lname, :NR).try(&.vstr) || QtCore.tl_hvname(lname)

    pchar = MAP_PCHAR[pchar[0]]? || pchar

    "#{fname_vstr}#{pchar}#{lname_vstr}"
  end

  MAP_PCHAR = {
    "、" => ", ",
    "､" => ", ",
    "･" => " ",
    "‧" => " ",
  }

  def init_od(zstr : String)
    if zstr[0] == '第'
      "thứ #{tl_unit(zstr[1..])}"
    else
      tl_unit(zstr)
    end
  end

  def init_cd_dedup(zstr : String)
    return unless zstr.size == 3
    return unless zstr[0] == '一' && zstr[1] == zstr[2]

    get?(zstr, :QP).try(&.vstr) || begin
      qzstr = zstr[-1].to_s
      qnode = get?(qzstr, :M) || get_alt?(qzstr)
      qvstr = qnode.try(&.vstr) || qzstr

      "từng #{qvstr} từng #{qvstr}"
    end
  end

  def init_cd(zstr : String)
    if qnode = init_cd_dedup(zstr)
      return qnode
    end

    if zstr.starts_with?("分之")
      sufx = " phần"
      zstr = zstr[2..]
    else
      sufx = ""
    end

    if q_term = get?(zstr[-1].to_s, :M)
      sufx = " #{q_term.vstr}#{sufx}"
      zstr = zstr[0..-2]
    end

    vstr = tl_unit(zstr)
    sufx.empty? ? vstr : "#{vstr}#{sufx}"
  end

  DECIMAL_SEP = {
    '点' => " chấm ",
    '．' => ".",
    '／' => "/",
  }

  def tl_unit(zstr : String)
    return CharUtil.to_halfwidth(zstr) if zstr =~ /^[０-９．，－：～％]$/
    real_part, sep_char, fract_part = zstr.partition(/[点．／]/)

    real_vstr = TlUnit.translate(real_part)
    return real_vstr if sep_char.empty?

    if fract_part.empty?
      sep_vstr = get_alt?(sep_char).try(&.vstr) || sep_char
      return "#{real_vstr} #{sep_vstr}"
    end

    sep_vstr = DECIMAL_SEP[sep_char[0]]
    fractional_vstr = fract_part.empty? ? "" : TlUnit.translate(fract_part)

    "#{real_vstr}#{sep_vstr}#{fractional_vstr}"
  rescue ex
    Log.error(exception: ex) { zstr }
    zstr
  end

  def init_vv(zstr : String) : String
    QtCore.tl_hvword(zstr)
  end
end
