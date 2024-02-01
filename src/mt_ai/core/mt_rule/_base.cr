require "../mt_data/*"
require "../mt_util/*"
require "../mt_dict"

class MT::AiCore
  def init_from_zstr(zstr : String, epos : MtEpos, attr : MtAttr = :none) : {String, MtAttr}
    case
    when epos.em?
      vstr = zstr
    when epos.pu?, epos.url?
      vstr = CharUtil.normalize(zstr)
    when epos.od?
      vstr = TlUnit.translate_od(zstr)
    when epos.cd?
      vstr = TlUnit.translate_cd(zstr)
    when epos.qp?
      vstr = TlUnit.translate_mq(zstr) || QtCore.tl_hvword(zstr, false)
    when epos.nr?
      vstr = @name_qt.tl_name(zstr, wrap: true)
      # TODO: translate time
    when epos.noun?
      vstr, noun_attr = QtCore.noun_qt.tl_noun(zstr)
      attr |= noun_attr
    when epos.verb?
      vstr = QtCore.verb_qt.tl_term(zstr, :VV)
    when epos.adjt?
      vstr = QtCore.adjt_qt.tl_term(zstr, :VA)
    else
      vstr = @qt_core.translate(zstr, false)
    end

    {vstr, attr}
  end

  private def init_pair_node(head : MtNode, tail : MtNode,
                             epos : MtEpos, attr : MtAttr = tail.attr,
                             zstr = "#{head.zstr}#{tail.zstr}", &)
    attr = attr.turn_off(MtAttr[Sufx, Prfx])
    body = @mt_dict.get_defn?(zstr, epos) || yield
    MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: head.from)
  end

  private def init_pair_node(head : MtNode, tail : MtNode,
                             epos : MtEpos, attr : MtAttr = tail.attr,
                             zstr = "#{head.zstr}#{tail.zstr}", flip : Bool = false)
    init_pair_node(head: head, tail: tail, epos: epos, attr: attr, zstr: zstr) do
      MtPair.new(head, tail, flip: flip)
    end
  end

  private def init_list_node(list : Array(MtNode),
                             epos : MtEpos, attr : MtAttr = :none,
                             zstr = list.join(&.zstr), from = list[0].from)
    body = @mt_dict.get_defn?(zstr, epos) || list
    MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
  end

  private def init_defn(zstr : String, epos : MtEpos, attr : MtAttr = :none)
    @mt_dict.get_defn?(zstr, epos, false) || begin
      vstr, attr = init_from_zstr(zstr, epos, attr)
      @mt_dict.add_temp(zstr, vstr, attr, epos)
    end
  end
end
