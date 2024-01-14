# require "./ai_term"

class MT::AiCore
  private def init_pair(head : MtTerm, tail : MtTerm,
                        epos : MtEpos, attr : MtAttr = tail.attr,
                        zstr = "#{head.zstr}#{tail.zstr}", flip : Bool = false)
    init_pair(head: head, tail: tail, epos: epos, attr: attr, zstr: zstr) do
      MtPair.new(head, tail, flip: flip)
    end
  end

  private def init_pair(head : MtTerm, tail : MtTerm,
                        epos : MtEpos, attr : MtAttr = tail.attr,
                        zstr = "#{head.zstr}#{tail.zstr}", &)
    body = init_defn(zstr, epos: epos, attr: attr, mode: 0) || yield

    MtTerm.new(
      body: body,
      zstr: zstr,
      epos: epos,
      attr: attr,
      from: head.from
    )
  end
end
