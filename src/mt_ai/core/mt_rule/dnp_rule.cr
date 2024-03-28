# require "./ai_term"

class MT::AiCore
  def fix_dnp_pair!(term : MtNode, body : MtPair)
    head, tail = body.head, body.tail
    body.flip = true
    term.attr = :at_t

    return unless tail.zstr == "的"

    case
    when head.epos.noun? || head.epos.pn?
      head = head.inner_tail
      is_modi = head.attr.any?(MtAttr[Ndes, Ntmp]) || !(head.epos.noun? || head.epos.pn?)
      tail.body = is_modi ? DefnData::DEG0 : DefnData::DEG1
    when head.epos.ip? && dnp_head_is_sv_ip?(head.body)
      tail.body = DefnData::DEG2
    when head.attr.at_h?
      tail.body = DefnData::DEG0
      term.attr = :at_h
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
