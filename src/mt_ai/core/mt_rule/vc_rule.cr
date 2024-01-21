# require "./ai_node"

class MT::AiCore
  def fix_dvp_node!(node : MtNode, body : MtPair)
    # TODO
  end

  def fix_dvp_pair!(node : MtNode, body : MtPair)
    # TODO
  end

  def fix_vcd_pair!(node : MtNode, body : MtPair)
    head, tail = body.head, body.tail
    PairDict.v_v_pair.fix_if_match!(tail, head)
  end

  def fix_vcp_pair!(node : MtNode, body : MtPair)
    head, tail = body.head, body.tail

    PairDict.v_c_pair.fix_if_match!(tail, head)
  end

  def fix_vrd_pair!(node : MtNode, body : MtPair)
    head, tail = body.head, body.tail

    # head.find_by_epos(:AS).try(&.add_attr!(MtAttr[Asis, Hide]))
    PairDict.v_c_pair.fix_if_match!(tail, head)
  end

  def fix_vnv_pair!(node : MtNode, body : MtPair)
    head, tail = body.head, body.tail
    fix_vnv_head!(head)

    case tail.zstr[0]
    when '没', '不'
      tail.body = "hay không"
    when '一'
      tail.body = "thử #{head.to_txt}"
    end
  end

  def fix_vnv_node!(node : MtNode, body : Array(MtNode))
    return unless body.size > 2
    head, infix, tail = body

    AiRule.fix_vnv_lhs!(head)

    case infix.zstr
    when "没", "不"
      infix.body = "không"
      tail.body = "hay"
      node.body = [head, tail, infix]
    when "一"
      infix.vstr = "thử"
    end
  end

  def fix_vnv_head!(head : MtNode) : Nil
    case head.zstr
    when "是" then head.body = "phải"
    when "会" then head.body = "biết"
    end
  end

  def fix_vpt_node!(node : MtNode, body : Array(MtNode))
    return unless tail = body[2]?
    tail.body = "nổi" if tail.zstr == "住"
  end
end
