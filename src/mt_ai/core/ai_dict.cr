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

  def get(zstr : String, ipos : Int8) : MtTerm
    get?(zstr, ipos) || get_alt?(zstr) || init(zstr, ipos)
  end

  def get?(zstr : String, ipos : Int8)
    @dict_list.each do |dict|
      dict.get?(zstr, ipos).try { |found| return found }
    end
  end

  def get_alt?(zstr : String)
    @dict_list.each do |dict|
      dict.any?(zstr).try { |found| return found }
    end
  end

  def init(zstr : String, ipos : Int8) : MtTerm
    case ipos
    when MtCpos::PU
      vstr = CharUtil.normalize(zstr)
      attr = MtAttr.parse_punct(zstr)
      @auto_dict.add(zstr, ipos, vstr, attr)
    when MtCpos::EM
      @auto_dict.add(zstr, ipos, zstr, MtAttr[Asis, Capx])
    when MtCpos["URL"]
      vstr = CharUtil.normalize(zstr)
      @auto_dict.add(zstr, ipos, vstr, MtAttr[Asis, Npos])
    when MtCpos::OD
      @auto_dict.add(zstr, ipos, init_od(zstr), :none)
    when MtCpos::CD
      @auto_dict.add(zstr, ipos, init_cd(zstr), :none)
    when MtCpos::VV
      @auto_dict.add(zstr, ipos, init_vv(zstr), :none)
    when MtCpos::NR
      vstr = init_nr(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    else
      vstr = QtCore.tl_hvword(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    end
  end

  def init_nr(zstr : String)
    # TODO: call special name translation engine

    fname, pchar, lname = zstr.partition(/[\p{P}]/)
    return QtCore.tl_hvname(zstr) if pchar.empty?

    fname_vstr = get?(fname, MtCpos::NR).try(&.vstr) || QtCore.tl_hvname(fname)
    lname_vstr = get?(lname, MtCpos::NR).try(&.vstr) || QtCore.tl_hvname(lname)

    pchar = MAP_PCHAR[pchar]? || pchar

    "#{fname_vstr}#{pchar}#{init_nr(lname)}"
  end

  def init_od(zstr : String)
    if zstr[0] == '第'
      "thứ #{tl_unit(zstr[1..])}"
    else
      tl_unit(zstr)
    end
  end

  def init_cd(zstr : String)
    case
    when zstr.starts_with?("分之") then "#{tl_unit(zstr[2..])} phần"
    else                              tl_unit(zstr)
    end
  end

  def tl_unit(zstr : String)
    case zstr
    when /^[０-９．，－：～ ％]$/
      CharUtil.to_halfwidth(zstr)
    else
      TlUnit.translate(zstr)
    end
  rescue ex
    Log.error(exception: ex) { zstr }
    zstr
  end

  MAP_PCHAR = {
    "､" => ", ",
    "･" => " ",
  }

  def init_vv(zstr : String) : String
    case
    when match = MtPair.vrd_pair.find_any(zstr)
      a_zstr, b_term = match
      a_term = get(a_zstr, MtCpos::VV)
      "#{a_term.vstr} #{b_term.a_vstr}"
    when zstr[-1] == '了'
      a_term = get(zstr[..-2], MtCpos::VV)
      "#{a_term.vstr} rồi"
    when zstr[0] == '一'
      b_term = get(zstr[1..], MtCpos::VV)
      "#{b_term.vstr} một phát"
    when zstr[0] == '吓'
      b_term = get(zstr[1..], MtCpos::VV)
      "dọa #{b_term.vstr}"
    else
      QtCore.tl_hvword(zstr)
    end
  end

  # def self.get_special?(astr : String, bstr : String)
  #   MtDict.special.get?(astr, bstr).try(&.[0])
  # end

  # def self.get_special?(astr : String, *bstr : String)
  #   MtDict.special.get?(astr, *bstr).try(&.[0])
  # end

  ###########

end
