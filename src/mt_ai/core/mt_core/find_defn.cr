require "./ai_term"

class MT::AiCore
  def find_defn(zstr : String, epos : MtEpos, attr : MtAttr = :none, mode : Int32 = 0)
    @dicts.each { |d| d.get?(zstr, epos).try { |x| return x } }
    return unless vstr = init_vstr(zstr, epos, mode: mode)
    defn = MtTerm.new(vstr: vstr, attr: attr, dnum: :autogen_0, fpos: epos)
    @dicts.last.add(zstr, epos, defn)
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
    @dicts.each { |d| d.any?(zstr).try { |x| return x.vstr } }
  end
end
