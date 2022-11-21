require "log"
require "yaml"
require "./mt_node"

module MT::MtRule
  extend self

  struct RawRule
    include YAML::Serializable

    getter rule : Array(String)
    getter ptag : String

    getter swap : Array(Int32)?
    getter mult : Float32 = 1.1
  end

  class Rule
    getter ptag : Int32
    getter mult : Float32
    getter swap : Array(Int32)?

    def initialize(@ptag, @mult = 1.1, @swap = nil)
    end

    def make(list : Array(MtNode))
      idx = list.first.idx
      len = list.sum(&.len)

      cost = list.sum(&.cost) * @mult

      ptag = @ptag > 0 ? @ptag : list[1 &- @ptag].ptag
      @swap.try { |x| list = swap_list(list, x) }

      MtExpr.new(list, idx: idx, len: len, ptag: ptag, cost: cost)
    end

    private def swap_list(list : Array(MtNode), order : Array(Int32))
      new_list = list.dup

      order.each_with_index do |new_idx, old_idx|
        new_list[new_idx] = list.unsafe_fetch(old_idx)
      end

      new_list
    end
  end

  class RuleTrie
    alias Suff = Hash(Int32, RuleTrie)

    property rule : Rule?
    property suff : Suff? = nil

    def [](ptag : Int32) : RuleTrie
      suff = @suff ||= Suff.new
      suff[ptag] ||= RuleTrie.new
    end

    @[AlwaysInline]
    def []?(ptag : Int32) : RuleTrie?
      @suff.try?(&.[ptag]?)
    end
  end

  RULES = RuleTrie.new

  def add_rule(input : RawRule)
    trie = RULES

    input.rule.each do |ptag_str|
      ptag = PosTag.map_tag(ptag_str)
      trie = trie[ptag]
    end

    swap = input.swap.try(&.map!(&.- 1))

    if input.ptag.starts_with?('$')
      ptag = -input.ptag[1..].to_i
    else
      ptag = PosTag.map_tag(input.ptag)
    end

    trie.rule = Rule.new(ptag, swap: swap, mult: input.mult)
  end

  files = Dir.glob("src/cvmtl/engine/mt_rule/**/*.yml")

  files.each do |file|
    File.open(file, "r") do |io|
      Array(RawRule).from_yaml(io).each { |rule| add_rule(rule) }
    end
  rescue err
    Log.error(exception: err) { file }
  end
end
