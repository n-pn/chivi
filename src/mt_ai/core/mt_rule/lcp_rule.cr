# require "./ai_term"

class MT::AiCore
  def fix_lcp_pair!(term : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail
    head = head.inner_head if head.epos.ip?

    case head.epos
    when .nt?
      fix_lcp_pair_with_nt!(body, head, tail)
    when .vp?
      fix_lcp_pair_with_vp!(body, head, tail)
    else
      body.flip = tail.epos.lc? && !tail.attr.at_t?
    end
  end

  def fix_lcp_pair_with_nt!(body, head, tail)
    case tail.zstr
    when "后", "之后"
      body.flip = false
      tail.body = "sau"
    else
      body.flip = !tail.attr.at_t?
    end
  end

  def fix_lcp_pair_with_vp!(body, head, tail)
    case tail.zstr
    when "后", "之后"
      body.flip = true
      tail.body = "sau khi"
    when "中"
      body.flip = true
      tail.body = "đang"
    else
      body.flip = !tail.attr.at_t?
    end
  end
end
