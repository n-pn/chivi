# require "./ai_term"

class MT::AiCore
  private def init_qp_np_pair(np_term : MtTerm, qp_term : MtTerm)
    init_pair(head: qp_term, tail: np_term, epos: :NP, attr: np_term.attr) do
      m_term = qp_term.find_by_epos(:M) || qp_term
      pp [m_term, qp_term, np_term]
      PairDict.m_n_pair.fix_if_match!(m_term, np_term)

      # TODO: split `OD`, fix `M` vstr
      MtPair.new(qp_term, np_term, flip: qp_term.attr.at_t?)
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
