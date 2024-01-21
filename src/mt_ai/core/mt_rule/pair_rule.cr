# require "./ai_term"

class MT::AiCore
  private def fix_mt_pair!(term : MtNode, body : MtPair) : Nil
    case term.epos
    when .dnp? then fix_dnp_pair!(term, body)
    when .dvp? then fix_dvp_pair!(term, body)
    when .lcp? then fix_lcp_pair!(term, body)
    when .vrd? then fix_vrd_pair!(term, body)
    when .vcd? then fix_vcd_pair!(term, body)
    when .vcp? then fix_vcp_pair!(term, body)
    when .vnv? then fix_vnv_pair!(term, body)
    when .qp?  then fix_qp_pair!(term, body)
    when .vp?  then fix_vp_pair!(term, body)
    when .dp?
      body.flip = !body.tail.attr.at_h?
    end
  end

  def fix_vp_pair!(term : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail

    case tail.epos
    when .noun?
      # TODO: extract main noun from noun phrase
      PairDict.v_n_pair.fix_if_match!(head, tail)
    else
      # TODO: handle more case
    end
  end

  def fix_qp_pair!(term : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail
    body.flip = head.epos.od? || tail.zstr.includes?('之')
  end
end
