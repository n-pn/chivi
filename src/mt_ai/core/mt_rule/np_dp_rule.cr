# require "./ai_term"

class MT::AiCore
  private def init_dp_np_pair(np_term : MtTerm, dp_term : MtTerm)
    init_pair(head: dp_term, tail: np_term, epos: :NP) do
      dt_term, qp_term = split_dp_term(dp_term, body: dp_term.body)
      np_term = init_qp_np_pair(np_term: np_term, qp_term: qp_term) if qp_term
      MtPair.new(dt_term, np_term, flip: !dt_term.attr.at_h?)
    end
  end

  private def split_dp_term(term : MtTerm, body : MtPair)
    {body.head, body.tail}
  end

  private def split_dp_term(term : MtTerm, body : Array(MtTerm))
    dt_node = body[0]
    qp_node = init_term(body[1..], epos: :QP, attr: :none)
    {dt_node, qp_node}
  end

  private def split_dp_term(term : MtTerm, body : MtDefn | MtTerm)
    fchar = term.zstr[0]
    return {term, nil} if term.zstr.size == 1 || !fchar.in?('这', '那')

    dt_body = MtDefn.new(vstr: fchar == '这' ? "này" : "kia", dnum: :root2)
    dt_term = MtTerm.new(epos: :DT, attr: :none, zstr: fchar.to_s, body: dt_body, from: term.from)

    qp_zstr = term.zstr[1..]
    qp_body = init_defn(qp_zstr, :QP) || raise "invalid #{qp_zstr}!"
    qp_term = MtTerm.new(body: qp_body, zstr: qp_zstr, epos: :QP, from: term.from &+ 1)

    {dt_term, qp_term}
  end
end
