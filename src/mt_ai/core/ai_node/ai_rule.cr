require "./ai_node"
require "./ai_rule/*"

module MT::AiRule
  extend self

  def split_dp(node : AiNode)
    case node
    when M1Node
      fchar = node.zstr[0]
      return {node, nil} unless fchar.in?('这', '那') && node.zstr.size > 1

      left = M0Node.new(fchar.to_s, cpos: "DT", _idx: node._idx, ipos: MtCpos::DT)
      right = M0Node.new(node.zstr[1..], cpos: "QP", _idx: node._idx &+ 1, ipos: MtCpos::QP)

      {left, right}
    when M2Node
      {node.left, node.right}
    else
      {node, nil}
    end
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
