require "../../_util/char_util"

require "./mt_dict"
require "./mt_node"
require "./mt_rule"
require "./basic_ner"

class M2::MtData
  include MtSeri

  record TopNode, node : MtNode, cost : Int32
  alias AllNode = Hash(Int32, MtNode)

  @raw_chars = [] of Char
  @inp_chars = [] of Char # normalized input

  @top_nodes = [] of MtNode
  @top_costs = [] of Int32

  getter all_nodes = [] of Hash(String, AllNode)
  getter ner_terms = [] of MtTerm?

  def initialize(input : String)
    @raw_chars = input.chars
    @upper = @raw_chars.size

    @raw_chars.each do |raw_char|
      inp_char = normalize(raw_char).upcase
      @inp_chars << inp_char

      @top_costs << 0
      @top_nodes << MtTerm.new(inp_char)
      @all_nodes << Hash(Int32, AllNode).new
    end
  end

  def normalize(char : Char)
    CharUtil.fullwidth?(raw_char) ? CharUtil.to_halfwidth(raw_char) : raw_char
  end

  def run_ner!(start = 0)
    @ner_nodes = BasicNER.detect_all(@inp_chars, idx: start)
  end

  def build!(dicts : Array(MtDict))
    @upper.downto(0) do |idx|
      if ner_term = @ner_nodes[idx]?
        add_node!(ner_term, idx: idx)
      end

      dicts.each do |dict|
        dict.scan(@inp_chars, start: idx) do |terms|
          terms.each { |term| add_node!(term, idx: idx) }
        end
      end
    end
  end

  def add_node!(node : MtNode, idx : Int32)
    all_nodes = @all_nodes.unsafe_fetch(idx)

    if pos_nodes = all_nodes[node.ptag]?
      pos_nodes[node.size]?.try { |curr| return if node.cost < curr.cost }
    else
      pos_nodes = all_nodes[node.ptag] = AllNode.new
    end

    pos_nodes[node.size] = node

    top_cost = @top_costs.unsafe_fetch(idx)
    new_cost = node.cost &+ @top_costs.unsafe_fetch(idx &+ node.size)

    if new_cost > top_cost
      @top_nodes[idx] = node
      @top_costs[idx] = new_cost
    end

    # ptags = PosTag::ROLE_MAP[node.ptag]? || [node.ptag]
    # puts [node, PosTag.tag_str(node.ptag), PosTag.tag_str(ptags)]

    return unless rule_node = MtRule.get_node(node.ptag)
    apply_rule!(node, rule_node, idx: idx)
  end

  private def apply_rule!(node : MtNode, rule_node : MtRule::RuleNode, idx : Int32)
    if rule = rule_node.rule
      rule.call(self, node, idx)
    end

    pair_rules = rule_node.hash
    return if pair_rules.empty?

    succ_nodes = @all_nodes[idx &+ node.size]
    return if succ_nodes.empty?

    # pp pair_rules, succ_nodes

    if succ_nodes.size < pair_rules.size
      succ_nodes.each do |ptag, nodes|
        next unless pair_rule = pair_rules[ptag]?

        nodes.each_value do |succ|
          pair_rule.call(self, node, succ, idx)
        end
      end
    else
      pair_rules.each do |ptag, pair_rule|
        next unless nodes = succ_nodes[ptag]?

        nodes.each_value do |succ|
          pair_rule.call(self, node, succ, idx)
        end
      end
    end
  end

  # private def apply_rule_all!(list : Array(MtNode), trie : MtRule::Trie, nodes : AllNode,
  #                             idx : Int32, size : Int32)
  #   nodes.each_value do |node|
  #     next_list = list.dup
  #     next_list << node
  #     apply_rule!(next_list, trie, idx, size &+ node.size)
  #   end
  # end

  # private def make_node(list : Array(MtNode), rule : MtRule::Rule, idx : Int32, size : Int32)
  #   cost = list.sum(&.cost) &+ 10 &* list.size &* (list.size &- 1) + rule.cost

  #   ptag = rule.ptag < 0 ? list[-rule.ptag &- 1].ptag : rule.ptag

  #   rule.swap.try { |x| list = swap_list(list, x) }
  #   MtExpr.new(list, size: size, ptag: ptag, cost: cost)
  # end

  # private def swap_list(list : Array(MtNode), swap : Array(Int32))
  #   new_list = list.dup

  #   swap.each_with_index do |new_idx, old_idx|
  #     new_list[old_idx] = list.unsafe_fetch(new_idx)
  #   end

  #   new_list
  # end

  def each(&)
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
