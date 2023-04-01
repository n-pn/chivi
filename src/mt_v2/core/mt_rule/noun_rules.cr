require "./_rule_base"

module M2::MtRule
  # single-word nouns or names
  def_rule :NN do
    add_node(root, NP_Node.new(head), idx: idx)
  end

  copy_rule :NT, NN
  copy_rule :NR, NN

  # noun-noun compounds
  def_rule :NN, :NN do
    # TODO: check flip condition
    noun = MtPair.new(head, secd, flip: true)
    add_node(root, noun, idx: idx)
  end

  # time-time compounds
  def_rule :NT, :NT do
    noun = MtPair.new(head, secd, rank: 3, flip: true)
    add_node(root, noun, idx: idx)
  end

  # word-level coordinations
  def_rule :NN, :CC do
    tail_idx = idx &+ head.size &+ secd.size

    tail_map = root.all_nodes[tail_idx]
    return unless tail_nodes = tail_map[:NN]?

    tail_nodes.each_value do |tail_node|
      # TODO: check similarity
      # TODO: combine with ETC tag

      list = Slice[head, secd, tail_node]
      noun = MtExpr.new(list, :NN, rank: 3)
      add_node(root, noun, idx: idx)
    end
  end

  # proper nouns formed by NR + one or more NNs
  def_rule :NR, :NN do
    # TODO: check flip condition
    # seperate between loc/org and person with titles
    noun = MtPair.new(head, secd, flip: true)
    add_node(root, noun, idx: idx)
  end

  # space names + space names
  def_rule :NR_s, :NR_s do
    noun = MtPair.new(head, secd, ptag: :NR_s, rank: 4, flip: true)
    add_node(root, noun, idx: idx)
  end

  # space names + space (org/loc) suffix
  def_rule :NR_s, :NN_ss do
    noun = MtPair.new(head, secd, ptag: :NR_s, rank: 4, flip: true)
    add_node(root, noun, idx: idx)
  end

  # human names + title/honorific (suffix)
  def_rule :NR_h, :NN_hs do
    # TODO: Check if NR_h already contains honorific
    noun = MtPair.new(head, secd, ptag: :NR_h, rank: 5, flip: false)
    add_node(root, noun, idx: idx)
  end

  # quantiy phrase + np
  def_rule :QP_n, :NP do
    noun = NP_Node.new(head, secd, rank: 4)
    add_node(root, noun, idx: idx)
  end
end
