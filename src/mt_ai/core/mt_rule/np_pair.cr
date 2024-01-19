# require "./ai_term"

class MT::AiCore
  def fix_np_pair!(body : MtPair)
    head, tail = body.head, body.tail

    if !head.epos.noun?
      body.flip = !head.attr.at_h?
    elsif head.epos.nr?
      body.flip = flip_noun_pair?(head, tail)
    end

    body
  end

  def flip_noun_pair?(head : MtTerm, tail : MtTerm)
    return true unless tail.attr.sufx?
    return tail.attr.at_h? unless tail.attr.nper?

    tail.epos = MtEpos::NH

    if defn = init_defn(tail.zstr, :NH)
      tail.attr = defn.attr
      tail.body = defn
    end

    tail.attr.at_h?
  end
end
