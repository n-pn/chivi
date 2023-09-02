require "../ai_node"

module MT::AiRule
  def read_vp!(dict : AiDict, orig : Array(AiNode)) : Array(AiNode)
    head = [] of AiNode
    base = [] of AiNode
    tail = [] of AiNode

    idx = 0
    max = orig.size

    stem : String? = nil

    orig.reverse_each do |node|
      next unless node.cpos.in?("VP", "VV")
      stem = node.first.zstr
    end

    after_obj = false

    while idx < max
      node = orig.unsafe_fetch(idx)
      idx += 1

      case node.cpos
      when "ADVP"
        node = heal_advp!(dict, node)
        if after_obj
          base.push(node)
        elsif node.pecs.post?
          tail.unshift(node)
        else
          head.push(node)
        end
      when "PP"
        node = heal_pp!(dict, node, stem || "_")

        if after_obj
          base.push(node)
        elsif node.pecs.post?
          tail.unshift(node)
        else
          head.push(node)
        end
      when "NP", "IP", "CP"
        base.push(node)
        after_obj = true
      else
        base.push(node)
      end
    end

    # pp [base, "base"]
    # pp [head, "head"]
    # pp [tail, "tail"]

    head.concat(base).concat(tail)
  end
end
