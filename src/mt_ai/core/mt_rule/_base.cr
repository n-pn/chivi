require "../mt_data/*"
require "../mt_util/*"
require "../mt_dict"

class MT::AiCore
  def translate_str(zstr : String, epos : MtEpos) : String
    case
    when epos.em? then zstr
    when epos.pu?, epos.url?
      CharUtil.normalize(zstr)
    when epos.od?
      TlUnit.translate_od(zstr)
    when epos.cd?
      TlUnit.translate_od(zstr)
    when epos.qp?
      TlUnit.translate_mq(zstr) || QtCore.tl_hvword(zstr)
    when epos.nr?
      @name_qt.translate(zstr, cap: true)
    else
      # TODO: change to fast translation mode
      # TODO: handle verb/noun/adjt translation
      QtCore.tl_hvword(zstr)
    end
  end
end
