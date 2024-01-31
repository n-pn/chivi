# require "./ai_term"

class MT::AiCore
  private def init_qp_np_pair(np_node : MtNode, qp_node : MtNode)
    init_pair_node(head: qp_node, tail: np_node, epos: :NP, attr: np_node.attr) do
      case qp_body = qp_node.body
      when MtPair
        np_node = init_qp_np_pair(np_node, qp_body.tail)
        qp_node = qp_body.head
      end

      PairDict.m_n_pair.fix_if_match!(qp_node, np_node)
      MtPair.new(qp_node, np_node, flip: qp_node.epos.od? || qp_node.attr.at_t?)
    end
  end

  # private def add_qp_to_list(list, qp_node, nn_node) : Nil
  #   m_node = qp_node.find_by_epos(:M) || qp_node
  #   MtPair.m_n_pair.fix_if_match!(m_node, nn_node)

  #   unless qp_node.first.epos.od?
  #     list.unshift(qp_node)
  #     return
  #   end

  #   case qp_node
  #   when M1Node
  #     list.push(qp_node)
  #   when M2Node
  #     list.push(qp_node.lhsn)
  #     list.unshift(qp_node.rhsn)
  #   else
  #     # TODO: handle M3Node and MxNode
  #     list.unshift(qp_node)
  #   end
  # end
end
