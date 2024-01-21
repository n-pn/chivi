# require "./mt_node"

class MT::AiCore
  private def fix_mt_pair!(node : MtNode, body : MtPair) : Nil
    case node.epos
    when .dnp? then fix_dnp_pair!(node, body)
    when .dvp? then fix_dvp_pair!(node, body)
    when .lcp? then fix_lcp_pair!(node, body)
    when .vrd? then fix_vrd_pair!(node, body)
    when .vcd? then fix_vcd_pair!(node, body)
    when .vcp? then fix_vcp_pair!(node, body)
    when .vnv? then fix_vnv_pair!(node, body)
    when .qp?  then fix_qp_pair!(node, body)
    when .vp?  then fix_vp_pair!(node, body)
    when .dp?
      body.flip = !body.tail.attr.at_h?
    end
  end

  def fix_vp_pair!(node : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail

    case tail.epos
    when .noun?
      # TODO: extract main noun from noun phrase
      PairDict.v_n_pair.fix_if_match!(head, tail)
    else
      # TODO: handle more case
    end
  end

  def fix_qp_pair!(node : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail
    body.flip = head.epos.od? || tail.zstr.includes?('之')
  end
end
