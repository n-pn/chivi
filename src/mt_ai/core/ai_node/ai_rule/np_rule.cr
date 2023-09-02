require "../ai_node"

module MT::AiRule
  def read_np!(dict : AiDict, orig : Array(AiNode)) : Array(AiNode)
    head = [] of AiNode
    base = [] of AiNode
    tail = [] of AiNode

    idx = orig.size &- 1

    while idx >= 0
      node = orig.unsafe_fetch(idx)
      idx -= 1

      case node.cpos
      when "QP" then base.unshift(node)
      when "DP" then add_dp_node(base, node)
      when "CLP"
        # FIXME: split phrase if first element is CD
        head.unshift(node)
      when "DNP"
        if node.last.term.try(&.pecs.prep?)
          base.unshift(node)
        else
          base.push(node)
        end
      when "PU"
        # TODO: check flipping
        nest, idx = read_pu!(dict, orig, node, idx)
        base.concat(nest)
      when "PRN"
        tail.unshift(node)
        node = orig.unsafe_fetch(idx)
        next unless node.zstr[0] == '，'
        tail.unshift(node)
        idx -= 1
      else
        base.push(node)
      end
    end

    head.concat(base).concat(tail)
  end

  private def add_dp_node(data : Array(AiNode), node : AiNode) : Nil
    if node.is_a?(M2Node)
      left, right = {node.left, node.right}
      data.unshift(node.right)

      left_dp?(node.left) ? data.unshift(node.left) : data.push(node.left)
    else
      # TODO: check pecs
      data.unshift(node)
    end
  end

  ###

  def left_dp?(node : AiNode)
    node.zstr.in?("")
  end
end
