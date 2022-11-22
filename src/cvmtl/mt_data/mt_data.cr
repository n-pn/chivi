require "../../_util/char_util"

require "./mt_dict"
require "./mt_node"
require "./mt_rule"

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

      @top << MtTerm.new(inp_char.to_s, 0, 1, 0, 0.0)
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

    return unless ptags = PosTag::ROLE_MAP[node.ptag]?

    all_curr = @all.unsafe_fetch(idx)
    ptags.each do |ptag|
      all_curr[ptag] << node
      next unless rule_trie = MtRule.get_rule(ptag)
      apply_rule!([node] of MtNode, rule_trie, idx: idx, size: node.size)
    end
  end

  private def apply_rule!(list : Array(MtNode), trie : MtRule::Trie, idx : Int32, size : Int32)
    if rule = trie.rule
      node = make_node(list, rule, idx: idx, size: size)
      add_node!(node, idx: idx)
    end

    return unless (trie_hash = trie.suff) && (all_succ = @all[idx &+ size]?)

    if trie_hash.size > all_succ.size
      all_succ.each do |ptag, nodes|
        next unless next_trie = trie_hash[ptag]?
        apply_rule_all!(list, next_trie, nodes, idx: idx, size: size)
      end
    else
      trie_hash.each do |ptag, next_trie|
        next unless nodes = all_succ[ptag]?
        apply_rule_all!(list, next_trie, nodes, idx: idx, size: size)
      end
    end
  end

  private def apply_rule_all!(list : Array(MtNode), trie : MtRule::Trie, nodes : Array(MtNode),
                              idx : Int32, size : Int32)
    nodes.each do |node|
      next_list = list.dup
      next_list << node
      apply_rule!(next_list, trie, idx, size &+ node.size)
    end
  end

  private def make_node(list : Array(MtNode), rule : MtRule::Rule, idx : Int32, size : Int32)
    cost = list.sum(&.cost) * rule.mult
    ptag = rule.ptag < 0 ? list[1 &- rule.ptag].ptag : rule.ptag

    rule.swap.try { |x| list = swap_list(list, x) }
    MtExpr.new(list, size: size, ptag: ptag, cost: cost)
  end

  private def swap_list(list : Array(MtNode), swap : Array(Int32))
    new_list = list.dup

    swap.each_with_index do |new_idx, old_idx|
      new_list[new_idx] = list.unsafe_fetch(old_idx)
    end

    new_list
  end

  def to_txt : String
    String.build { |io| to_txt(io) }
  end

  def each
    idx = 0

    while idx < @upper
      node = @top.unsafe_fetch(idx)
      yield node, idx
      idx &+= node.size
    end
  end

  def to_txt(io : IO)
    each do |node|
      io << ' ' # unless ...
      node.to_txt(io)
    end
  end

  def to_mtl(io : IO)
    each do |node, idx|
      io << "\t " # unless ...
      node.to_mtl(io, idx: idx)
    end
  end

  def inspect(io : IO = STDOUT)
    each do |node, idx|
      inspect(io, node, idx)
    end
  end

  def inspect(io : IO, node : MtNode, idx : Int32, pad = 0) : Nil
    pad_left = pad > 0 ? " " * pad : ""
    io << pad_left

    tag = node.tag_str.colorize.light_cyan

    case node
    when MtTerm
      io << '[' << node.val.colorize.light_yellow.bold << ']'

      key = @raw_chars[idx, node.size].join.colorize.blue
      io << ' ' << key << ' ' << tag
      io << ' ' << node.dic << ' ' << idx.colorize.dark_gray
    when MtExpr
      io << '{' << tag << '}' << '\n'

      node.list.each do |child|
        inspect(io, child, idx, pad &+ 2)
        idx += child.size
      end

      io << pad_left << '{' << '/' << tag << '}'
    end

    io << '\n'
  end
end
