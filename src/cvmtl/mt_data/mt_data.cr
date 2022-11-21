require "../../_util/char_util"

require "./mt_dict"
require "./mt_node"

class MT::MtData
  @raw_chars = [] of Char
  @inp_chars = [] of Char # normalized input

  @top = [] of MtNode
  @all = [] of Hash(Int32, Array(MtNode))

  @ner = [] of MtTerm?

  def initialize(input : String)
    @raw_chars = input.chars
    @upper = @raw_chars.size

    @raw_chars.each do |raw_char|
      inp_char = CharUtil.fullwidth?(raw_char) ? CharUtil.to_halfwidth(raw_char) : raw_char
      @inp_chars << inp_char

      @top << MtTerm.new(inp_char.to_s, 0, 1, 0, 0)
      @all << Hash(Int32, Array(MtNode)).new { |h, k| h[k] = [] of MtNode }
    end
  end

  def construct!(dicts : Array(MtDict))
    @upper.downto(0) do |idx|
      if term = @ner[idx]?
        add_node!(term, idx: idx)
      end

      dicts.each do |dict|
        dict.scan(@inp_chars, start: idx) do |terms|
          terms.each { |x| add_node!(x, idx: idx) }
        end
      end
    end
  end

  def add_node!(node : MtNode, idx : Int32)
    prev_top = @top.unsafe_fetch(idx)
    @top[idx] = node if node.cost > prev_top.cost

    return unless ptags = PosTag::ROLE_MAPS[node.ptag]?

    ptags.each do |ptag|
      @all[ptag] << node
      next unless rule_trie = MtRule::RuleTrie[ptag]?
      apply_rule!([node], rule_trie, idx: idx, size: node.size)
    end
  end

  private def apply_rule!(list : Array(MtNode), trie : RuleTrie, idx : Int32, size : Int32)
    if rule = trie.rule
      node = make_node(list, rule, idx: idx, size: size)
      add_node!(node, idx: idx)
    end

    return unless all_next = @all[idx &+ size]?

    if trie.size > succ.size
      all_next.each do |ptag, nodes|
        next unless next_trie = trie[ptag]?
        apply_rule_all!(list, next_trie, nodes, idx: idx, size: size)
      end
    else
      trie.each do |ptag, next_trie|
        next unless nodes = all_next[ptag]?
        apply_rule_all!(list, next_trie, nodes, idx: idx, size: size)
      end
    end
  end

  private def apply_rule_all!(list : Array(MtNode), trie : RuleTrie, nodes : Array(MtNode),
                              idx : Int32, size : Int32)
    nodes.each do |node|
      next_list = list.dup
      next_list << node
      apply_rule!(next_list, trie, idx, size &+ node.size)
    end
  end

  private def make_node(list : Array(MtNode), rule : MtRule, idx : Int32, size : Int32)
    cost = list.sum(&.cost) * rule.mult
    ptag = rule.ptag < 0 ? list[1 &- rule.ptag].ptag : rule.ptag

    rule.swap.try { |x| list = swap_list(list, x) }
    MtExpr.new(list, idx: idx, size: size, ptag: ptag, cost: cost)
  end

  private def swap_list(list : Array(MtNode), swap : Array(Int32))
    new_list = list.dup

    swap.each_with_index do |new_idx, old_idx|
      new_list[new_idx] = list.unsafe_fetch(old_idx)
    end

    new_list
  end
end
