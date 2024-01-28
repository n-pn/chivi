# require "./ai_term"

class MT::AiCore
  def fix_dnp_pair!(term : MtNode, body : MtPair)
    head, tail = body.head, body.tail
    body.flip = true

    if !head.epos.noun? && head.attr.at_h?
      term.attr = :at_h
      return
    end

    term.attr = :at_t
    return unless tail.zstr == "的"

    head_body = head.body
    head = head_body if head_body.is_a?(MtNode)

    case
    when head.attr.any?(MtAttr[Ndes, Ntmp])
      tail.body = MtDefn::DEG0
    when head.epos.noun?
      tail.body = MtDefn::DEG1
    when head.epos.ip? && dnp_head_is_sv_ip?(head.body)
      tail.body = MtDefn::DEG2
    else
      tail.body = MtDefn::DEG0
    end
  end

  private def dnp_head_is_sv_ip?(body)
    case body
    when MtPair then body.head.epos.noun?
    when Array  then body.first.epos.noun?
    else             false
    end
  end
end
