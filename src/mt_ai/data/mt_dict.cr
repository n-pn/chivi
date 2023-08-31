require "sqlite3"

require "../../mtapp/sp_core"
require "../util/*"
require "./vp_defn"

class AI::MtDict
  @main_dict : VpDefn
  @auto_dict : VpDefn

  @@cache = {} of String => self

  def self.load(pdict : String)
    @@cache[pdict] ||= new(pdict)
  end

  def initialize(pdict : String = "combined")
    @main_dict = VpDefn.load(pdict)
    @auto_dict = VpDefn.new(pdict, :autogen)

    @dict_list = {
      VpDefn.essence,
      @main_dict,
      VpDefn.regular,
      @auto_dict,
      VpDefn.suggest,
    }
  end

  def get(zstr : String, cpos : String) : {String, VpPecs, Int32}
    get?(zstr, cpos) || get_alt?(zstr) || init(zstr, cpos)
  end

  def get?(zstr : String, cpos : String)
    @dict_list.each do |dict|
      dict.get?(zstr, cpos).try { |found| return found }
    end
  end

  def get_alt?(zstr : String)
    @dict_list.each do |dict|
      dict.any?(zstr).try { |found| return found }
    end
  end

  def init(zstr : String, cpos : String)
    pecs = VpPecs::None

    case cpos
    when "PU"
      vstr = CharUtil.normalize(zstr)
      pecs = VpPecs.parse_punct(zstr)
      @auto_dict.add(zstr, cpos, vstr, pecs)
    when "CD", "OD"
      vstr = QtNumber.translate(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    when "NR"
      # TODO: call special name translation engine
      vstr = MT::SpCore.tl_hvname(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    else
      vstr = MT::SpCore.tl_sinovi(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    end

    {vstr, pecs, VpDefn::Dtype::Autogen.to_i}
  end
end
