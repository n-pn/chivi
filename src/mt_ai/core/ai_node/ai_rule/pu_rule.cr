require "../ai_node"

module MT::AiRule
  PUNCT_MATCH_PAIR = {
    '”' => '“',
    '’' => '‘',
    '〉' => '〈',
    '〉' => '〈',
    '）' => '（',
  }

  def self.read_pu!(dict : AiDict, list : Enumerable(AiNode), tail : AiNode, idx : Int32)
    pu_char = tail.zstr[0]
    # TODO: ignore middot

    hd_char = PUNCT_MATCH_PAIR[pu_char]?

    data = [] of AiNode
    head = nil

    while idx >= 0
      node = list.unsafe_fetch(idx)

      if node.cpos != "PU" || (hd_char && hd_char != node.zstr[0])
        data.unshift(node)
        idx -= 1
        next
      end

      if hd_char
        head = node
        idx -= 1
      end

      break
    end

    data = read_np!(dict, data)

    data.push(tail)
    data.unshift(head) if head

    # pp [data, "pu_list"]

    {data, idx}
  end
end
