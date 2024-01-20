# require "./ai_term"

class MT::AiCore
  def fix_dvp_pair!(term : MtTerm, body : MtPair)
    # TODO
    # pp [lhsn, rhsn]
  end

  def fix_vcd_pair!(term : MtTerm, body : MtPair)
    head, tail = body.head, body.tail
    PairDict.v_v_pair.fix_if_match!(tail, head)
  end

  def fix_vcp_pair!(term : MtTerm, body : MtPair)
    head, tail = body.head, body.tail

    PairDict.v_c_pair.fix_if_match!(tail, head)
  end

  def fix_vrd_pair!(term : MtTerm, body : MtPair)
    head, tail = body.head, body.tail

    # head.find_by_epos(:AS).try(&.add_attr!(MtAttr[Asis, Hide]))
    PairDict.v_c_pair.fix_if_match!(tail, head)
  end


  def fix_vnv_pair!(term : MtTerm, body : MtPair)
    head, tail = body.head, body.tail
    fix_vnv_head!(head)

    case tail.zstr[0]
    when '没', '不'
      tail.body = "hay không"
    when '一'
      tail.body = "thử #{head.to_txt}"
    end
  end

  def fix_vnv_term!(term : MtTerm, body : Array(MtTerm))
    return unless body.size > 2
    head, infix, tail = body

    AiRule.fix_vnv_lhs!(head)

    case infix.zstr
    when "没", "不"
      infix.body = "không"
      tail.body = "hay"
      term.body = [head, tail, infix]
    when "一"
      infix.vstr = "thử"
    end
  end


  def fix_vnv_head!(head : MtTerm) : Nil
    case head.zstr
    when "是" then head.body = "phải"
    when "会" then head.body = "biết"
    end
  end




end
