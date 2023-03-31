require "./_rule_base"

module M2::MtRule
  # single-word nouns or names
  def nn(root : MtData, node : MtNode, idx : Int32)
    root.add_node!(NP_Node.new(node), idx: idx)
  end

  # noun-noun compounds
  def nn__nn(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    # TODO: check flip condition
    noun = MtPair.new(left, right, flip: true)
    root.add_node!(noun, idx: idx)
  end

  # time-time compounds
  def nt__nt(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    noun = MtPair.new(left, right, cost: 3, flip: true)
    root.add_node!(noun, idx: idx)
  end

  # word-level coordinations
  def nn__cc(root : MtData, left : MtNode, coord : MtNode, idx : Int32)
    right_idx = idx &+ left.size &+ coord.size

    right_map = root.all_nodes[right_idx]
    return unless right_nodes = right_map["NN"]?

    right_nodes.each_value do |right_node|
      # TODO: check similarity
      # TODO: combine with ETC tag

      list = Slice[left, coord, right_node]
      noun = MtExpr.new(list, "NN", cost: 3)
      root.add_node!(noun, idx: idx)
    end
  end

  # proper nouns formed by NR + one or more NNs
  def nr__nn(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    # TODO: check flip condition
    # seperate between loc/org and person with titles
    noun = MtPair.new(left, right, flip: true)
    root.add_node!(noun, idx: idx)
  end

  # space names + space names
  def nr_s__nr_s(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    noun = MtPair.new(left, right, ptag: "NR_s", cost: 4, flip: true)
    root.add_node!(noun, idx: idx)
  end

  # space names + space (org/loc) suffix
  def nr_s__nn_ss(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    noun = MtPair.new(left, right, ptag: "NR_s", cost: 4, flip: true)
    root.add_node!(noun, idx: idx)
  end

  # human names + title/honorific (suffix)
  def nr_h__nn_hs(root : MtData, left : MtNode, right : MtNode, idx : Int32)
    # TODO: Check if NR_h already contains honorific

    noun = MtPair.new(left, right, ptag: "NR_h", cost: 5, flip: false)
    root.add_node!(noun, idx: idx)
  end
end
