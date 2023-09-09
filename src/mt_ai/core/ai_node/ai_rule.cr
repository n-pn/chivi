require "./ai_node"
require "./ai_rule/*"

module MT::AiRule
  extend self

  def split_dp(node : AiNode)
    # TODO: split CD and M
    return {node, nil} unless node.is_a?(M2Node)
    {node.left, node.right}
  end

  PUNCT_MATCH_PAIR = {
    '“' => '”',
    '‘' => '’',
    '〈' => '〉',
    '〈' => '〉',
    '（' => '）',
  }

  def find_matching_pu(list : Array(AiNode), head : AiNode,
                       _idx = 0, _max = list.size)
    return unless match_char = PUNCT_MATCH_PAIR[head.zstr[0]]?

    while _idx < _max
      node = list.unsafe_fetch(_idx)
      _idx &+= 1
      return {node, _idx} if node.ipos == MtCpos::PU && node.zstr[-1] == match_char
    end
  end
end
