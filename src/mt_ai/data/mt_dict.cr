require "sqlite3"

require "../../mtapp/sp_core"
require "../util/*"
require "./vp_defn"

class AI::MtDict
  @main_dict : VpDefn
  @auto_dict : VpDefn

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

  def find(zstr : String, cpos : String) : {String, VpPecs, Int32}
    fallback = nil

    @dict_list.each do |dict|
      if found = dict.get(zstr, cpos)
        return found
      else
        fallback ||= dict.get_alt(zstr)
      end
    end

    fallback && !cpos.in?("CD", "OD") ? fallback : init(zstr, cpos)
  end

  def init(zstr : String, cpos : String)
    pecs = VpPecs::None

    case cpos
    when "PU"
      vstr = CharUtil.normalize(zstr)
      pecs = VpPecs.parse_punct(zstr)
      @auto_dict.add_defn(zstr, cpos, vstr, pecs)
    when "CD", "OD"
      vstr = QtNumber.translate(zstr)
      @auto_dict.add_defn(zstr, cpos, vstr, :none)
    when "NR"
      # TODO: call special name translation engine
      vstr = MT::SpCore.tl_hvname(zstr)
      @auto_dict.add_defn(zstr, cpos, vstr, :none)
    else
      vstr = MT::SpCore.tl_sinovi(zstr)
      @auto_dict.add_defn(zstr, cpos, vstr, :none)
    end

    {vstr, pecs, VpDefn::Dtype::Autogen.to_i}
  end
end
