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

  private def init_pair_node(head : MtNode, tail : MtNode,
                             epos : MtEpos, attr : MtAttr = tail.attr,
                             zstr = "#{head.zstr}#{tail.zstr}", &)
    match, _fuzzy = @mt_dict.get_defn?(zstr, epos)
    body = match || yield
    MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: head.from)
  end

  private def init_pair_node(head : MtNode, tail : MtNode,
                             epos : MtEpos, attr : MtAttr = tail.attr,
                             zstr = "#{head.zstr}#{tail.zstr}", flip : Bool = false)
    init_pair_node(head: head, tail: tail, epos: epos, attr: attr, zstr: zstr) do
      MtPair.new(head, tail, flip: flip)
    end
  end

  private def init_term(list : Array(MtNode),
                        epos : MtEpos, attr : MtAttr = :none,
                        zstr = list.join(&.zstr), from = list[0].from)
    body = init_defn(zstr, epos, attr) || begin
      case list.size
      when 1 then list[0]
      when 2 then MtPair.new(list[0], list[1])
      else        list
      end
    end

    MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
  end

  private def init_defn(zstr : String, epos : MtEpos, attr : MtAttr = :none)
    match, _fuzzy = @mt_dict.get_defn?(zstr, epos)
    return match if match

    return unless vstr = translate_str(zstr, epos)
    @mt_dict.add_temp(zstr, vstr, attr, epos)
  end
end
