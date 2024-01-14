require "../mt_data/*"
require "../mt_util/*"
require "../mt_dict"

class MT::AiCore
  def init_defn(zstr : String, epos : MtEpos,
                attr : MtAttr = :none, mode : Int32 = 0)
    match, fuzzy = @mt_dict.get_defn?(zstr, epos)
    return match if match
    return fuzzy if fuzzy && mode > 1

    return unless vstr = init_vstr(zstr, epos, mode: mode)
    @mt_dict.add_temp(zstr, vstr, attr, epos)
  end

  # modes: 0 => return if not found, 1: search for any values, 2: translate by any mean!
  def init_vstr(zstr : String, epos : MtEpos, mode = 0) : String?
    case
    when epos.em? then zstr
    when epos.pu?, epos.url?
      CharUtil.normalize(zstr)
    when epos.od?
      TlUnit.translate_od(zstr)
    when epos.cd?
      TlUnit.translate_od(zstr)
    when epos.qp?
      TlUnit.translate_mq(zstr)
    when epos.nr?
      @name_qt.translate(zstr, cap: true)
    when mode == 2
      QtCore.tl_hvword(zstr)
    end
  end

  private def init_term(list : Array(MtTerm),
                        epos : MtEpos, attr : MtAttr = :none,
                        zstr = list.join(&.zstr), from = list[0].from)
    body = init_defn(zstr, epos, attr, mode: 0) || begin
      case list.size
      when 1 then list[0]
      when 2 then MtPair.new(list[0], list[1])
      else        list
      end
    end

    MtTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
  end
end
