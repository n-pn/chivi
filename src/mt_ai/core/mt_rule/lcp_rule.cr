# require "./ai_term"

class MT::AiCore
  def fix_lcp_pair!(term : MtNode, body : MtPair) : Nil
    head, tail = body.head, body.tail

    case tail.zstr
    when ""
    else
      body.flip = !tail.attr.at_t?
    end
  end
end
