# require "./ai_node"

class MT::AiCore
  private def init_dp_np_pair(np_node : MtNode, dp_node : MtNode)
    init_pair_node(head: dp_node, tail: np_node, epos: :NP) do
      dt_node, qp_node = split_dp_node(dp_node, body: dp_node.body)
      np_node = init_qp_np_pair(np_node: np_node, qp_node: qp_node) if qp_node
      MtPair.new(dt_node, np_node, flip: !dt_node.attr.at_h?)
    end
  end

  private def split_dp_node(node : MtNode, body : MtPair)
    {body.head, body.tail}
  end

  private def split_dp_node(node : MtNode, body : Array(MtNode))
    dt_node = body[0]
    qp_node = init_list_node(body[1..], epos: :QP, attr: :none)
    {dt_node, qp_node}
  end

  private def split_dp_node(node : MtNode, body : MtDefn | MtNode)
    fchar = node.zstr[0]
    return {node, nil} if node.zstr.size == 1 || !fchar.in?('这', '那')

    dt_body = MtDefn.new(vstr: fchar == '这' ? "này" : "kia", dnum: :auto_fix)
    dt_node = MtNode.new(epos: :DT, attr: :none, zstr: fchar.to_s, body: dt_body, from: node.from)

    qp_zstr = node.zstr[1..]
    qp_body = init_defn(qp_zstr, :QP) || raise "invalid #{qp_zstr}!"
    qp_node = MtNode.new(body: qp_body, zstr: qp_zstr, epos: :QP, from: node.from &+ 1)

    {dt_node, qp_node}
  end
end
