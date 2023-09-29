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

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "pdict", @pdict.sub('/', ':')
      jb.field "sizes", {@main_dict.size, MtDict.regular.size, @auto_dict.size}
    }
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

  def init_nr(zstr : String)
    # TODO: call special name translation engine

    fname, pchar, lname = zstr.partition(/[\p{P}]/)
    return QtCore.tl_hvname(zstr) if pchar.empty?

    fname_vstr = get?(fname, :NR).try(&.vstr) || QtCore.tl_hvname(fname)
    lname_vstr = get?(lname, :NR).try(&.vstr) || QtCore.tl_hvname(lname)

    pchar = MAP_PCHAR[pchar[0]]? || pchar

    "#{fname_vstr}#{pchar}#{lname_vstr}"
  end

  MAP_PCHAR = {
    '､' => ", ",
    '･' => " ",
  }

  def init_od(zstr : String)
    if zstr[0] == '第'
      "thứ #{tl_unit(zstr[1..])}"
    else
      tl_unit(zstr)
    end
  end

  def init_cd(zstr : String)
    case
    when zstr.starts_with?("分之")
      "#{tl_unit(zstr[2..])} phần"
    else
      tl_unit(zstr)
    end
  end

  DECIMAL_SEP = {
    '点' => " chấm ",
    '．' => ".",
    '／' => "/",
  }

  def tl_unit(zstr : String)
    return CharUtil.to_halfwidth(zstr) if zstr =~ /^[０-９．，－：～％]$/
    integer_part, sep_char, fractional_part = zstr.partition(/[点．／]/)

    integer_vstr = TlUnit.translate(integer_part)
    return integer_vstr if sep_char.empty?

    sep_vstr = DECIMAL_SEP[sep_char[0]]
    fractional_vstr = fractional_part.empty? ? "" : TlUnit.translate(fractional_part)

    "#{integer_vstr}#{sep_vstr}#{fractional_vstr}"
  rescue ex
    Log.error(exception: ex) { zstr }
    zstr
  end

  def init_vv(zstr : String) : String
    case
    when match = MtPair.vrd_pair.find_any(zstr)
      a_zstr, b_term = match
      a_term = get(a_zstr, :VV)
      "#{a_term.vstr} #{b_term.a_vstr}"
    when zstr[-1] == '了'
      a_term = get(zstr[..-2], :VV)
      "#{a_term.vstr} rồi"
    when zstr[0] == '一'
      b_term = get(zstr[1..], :VV)
      "#{b_term.vstr} một phát"
    when zstr[0] == '吓'
      b_term = get(zstr[1..], :VV)
      "dọa #{b_term.vstr}"
    else
      QtCore.tl_hvword(zstr)
    end
  end
end
