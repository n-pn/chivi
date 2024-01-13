require "../ai_term"

class MT::AiCore
  def init_defn(zstr : String, epos : MtEpos,
                attr : MtAttr = :none, mode : Int32 = 0)
    @dicts.each { |d| d.get_defn?(zstr, epos).try { |x| return x } }

    return unless vstr = init_vstr(zstr, epos, mode: mode)
    defn = ZvDefn.new(vstr: vstr, attr: attr, dnum: :auto0, fpos: epos)
    @dicts.last[zstr].add_data(epos, defn) { MtWseg.new(zstr) }

    defn
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
      get_any_defn?(zstr) || QtCore.tl_hvword(zstr)
    when mode == 1
      get_any_defn?(zstr)
    end
  end

  def get_any_defn?(zstr : String)
    @dicts.each { |d| d.any_defn?(zstr).try { |x| return x.vstr } }
  end

  private def init_term(list : Array(AiTerm),
                        epos : MtEpos, attr : MtAttr = :none,
                        zstr = list.join(&.zstr), from = list[0].from)
    body = init_defn(zstr, epos, attr, mode: 0) || begin
      case list.size
      when 1 then list[0]
      when 2 then AiPair.new(list[0], list[1])
      else        list
      end
    end

    AiTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
  end
end
