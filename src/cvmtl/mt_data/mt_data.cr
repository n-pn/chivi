require "../../_util/char_util"

require "./mt_dict"
require "./mt_node"
require "./mt_rule"

class MT::MtData
  include MtSeri

  @raw_chars = [] of Char
  @inp_chars = [] of Char # normalized input

  alias All = Hash(Int32, MtNode)

  @top = [] of MtNode
  @all = [] of Hash(Int32, All)

  @ner = [] of MtTerm?

  def initialize(input : String)
    @raw_chars = input.chars
    @top_cost = [0_f64]
    @upper = @raw_chars.size

    @raw_chars.each do |raw_char|
      inp_char = CharUtil.fullwidth?(raw_char) ? CharUtil.to_halfwidth(raw_char) : raw_char
      @inp_chars << inp_char

      @top_cost << 0_f64
      @top << MtTerm.new(inp_char.to_s, 0, 1, 0, 0.0)
      @all << Hash(Int32, All).new { |h, k| h[k] = All.new }
    end
  end

  def construct!(dicts : Array(MtDict))
    @upper.downto(0) do |idx|
      if ner_term = @ner[idx]?
        add_node!(ner_term, idx: idx)
      end

      dicts.each do |dict|
        dict.scan(@inp_chars, start: idx) do |terms|
          terms.each do |term|
            term = term.dup
            term.idx = idx
            add_node!(term, idx: idx)
          end
        end
      end
    end
  end

  def debug(term : MtTerm)
    data = {
      key:  @raw_chars[term.idx, term.size].join,
      val:  term.val,
      dic:  term.dic,
      cost: term.cost,
    }

    puts data
  end

  def add_node!(node : MtNode, idx : Int32)
    # prev_top = @top.unsafe_fetch(idx)
    # @top_cost[idx] = node_cost if node.cost > prev_top.cost

    prev_cost = @top_cost.unsafe_fetch(idx)
    node_cost = node.cost + @top_cost.unsafe_fetch(idx &+ node.size)

    if node_cost > prev_cost
      @top[idx] = node
      @top_cost[idx] = node_cost
    end

    return unless ptags = PosTag::ROLE_MAP[node.ptag]?
    # puts [node, PosTag.tag_str(node.ptag), PosTag.tag_str(ptags)]

    all_curr = @all.unsafe_fetch(idx)

    ptags.each do |ptag|
      all_ptag = all_curr[ptag] ||= All.new
      all_ptag[node.size] = node if better_outcome?(all_ptag, node)

      next unless rule_trie = MtRule.get_rule(ptag)
      apply_rule!([node] of MtNode, rule_trie, idx: idx, size: node.size)
    end
  end

  private def better_outcome?(all : All, node : MtNode) : Bool
    return true unless prev = all[node.size]?
    return node.is_a?(MtTerm) || node.cost > prev.cost if !prev.is_a?(MtTerm)
    node.is_a?(MtTerm) && node.cost > prev.cost
  end

  private def apply_rule!(list : Array(MtNode), trie : MtRule::Trie, idx : Int32, size : Int32)
    if rule = trie.rule
      node = make_node(list, rule, idx: idx, size: size)
      add_node!(node, idx: idx)
    end

    return unless (trie_hash = trie.suff) && (all_succ = @all[idx &+ size]?)
    return if all_succ.empty?

    # pp trie_hash, all_succ

    if all_succ.size < trie_hash.size
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

  private def apply_rule_all!(list : Array(MtNode), trie : MtRule::Trie, nodes : All,
                              idx : Int32, size : Int32)
    nodes.each_value do |node|
      next_list = list.dup
      next_list << node
      apply_rule!(next_list, trie, idx, size &+ node.size)
    end
  end

  private def make_node(list : Array(MtNode), rule : MtRule::Rule, idx : Int32, size : Int32)
    cost = list.sum(&.cost) * rule.mult

    ptag = rule.ptag < 0 ? list[-rule.ptag &- 1].ptag : rule.ptag

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

  def each
    idx = 0

    while idx < @upper
      node = @top.unsafe_fetch(idx)
      yield node, idx
      idx &+= node.size
    end
  end

  def to_txt(apply_cap = true) : String
    String.build { |io| to_txt(io, apply_cap: apply_cap) }
  end

  def to_mtl(apply_cap = true) : String
    String.build { |io| to_mtl(io, apply_cap: apply_cap) }
  end

  def inspect(io : IO = STDOUT)
    each do |node|
      inspect(io, node)
    end
  end

  def inspect(io : IO, node : MtNode, pad = 0) : Nil
    pad_left = pad > 0 ? " " * pad : ""
    io << pad_left

    tag = node.tag_str.colorize.light_cyan

    case node
    when MtTerm
      io << '[' << node.val.colorize.light_yellow.bold << ']'

      key = @raw_chars[node.idx, node.size].join.colorize.blue
      io << ' ' << key << ' ' << tag
      io << ' ' << node.dic << ' ' << node.idx.colorize.dark_gray
    when MtExpr
      io << '{' << tag << '}' << '\n'
      node.each { |child| inspect(io, child, pad &+ 2) }
      io << pad_left << '{' << '/' << tag << '}'
    end

    io << '\n'
  end
end
