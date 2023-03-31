require "../../_util/char_util"

require "./mt_dict"
require "./mt_node"
require "./basic_ner"

class M2::MtData
  include MtSeri

  record TopNode, node : MtNode, cost : Int32
  alias AllNode = Hash(Int32, MtNode)

  getter inp_chars = [] of Char # normalized input
  @raw_chars = [] of Char

  @top_nodes = [] of MtNode
  @top_costs = [] of Int32

  getter all_nodes = [] of Hash(Symbol, AllNode)
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

  def add_node(node : MtNode, idx : Int32) : MtNode?
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

    node
  end

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
