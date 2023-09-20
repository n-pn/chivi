require "./ai_node"
require "./ai_rule/*"

module MT::AiRule
  extend self

  # def split_dp(node : AiNode, &)
  #   case node
  #   when M1Node
  #     if node.zstr.size < 2 || !node.zstr[0].in?('这', '那')
  #       yield node
  #     else
  #       lhsn = M0Node.new(node.zstr[0].to_s, epos: :DT, _idx: node._idx)
  #       rhsn = M0Node.new(node.zstr[1..], epos: :QP, _idx: node._idx + 1)

  #       yield lhsn
  #       yield rhsn
  #     end
  #   when M2Node
  #     yield node.lhsn
  #     yield node.rhsn
  #   else
  #     yield node
  #   end
  # end

  PUNCT_MATCH_PAIR = {
    '“' => '”',
    '‘' => '’',
    '〈' => '〉',
    '（' => '）',
  }

  def find_matching_pu(list : Array(AiNode), head : AiNode,
                       _idx = 0, _max = list.size)
    return unless match_char = PUNCT_MATCH_PAIR[head.zstr[0]]?

    while _idx < _max
      node = list.unsafe_fetch(_idx)
      _idx &+= 1
      return {node, _idx} if node.epos.pu? && node.zstr[-1] == match_char
    end
  end
end
