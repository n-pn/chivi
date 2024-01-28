# require "./ai_term"

class MT::AiCore
  def fix_lcp_pair!(term : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail
    head = head.inner_head if head.epos.ip?

    case tail.zstr
    when "后"
      case
      when head.epos.vp?
        body.tail.body = "sau khi"
        body.flip = true
      when head.epos.nt?
        body.flip = false
      else
        body.flip = true
      end
    else
      body.flip = !tail.attr.at_t?
    end
  end
end
