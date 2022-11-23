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
    getter cost : Int32 = 10
  end

  class Rule
    getter ptag : Int32
    getter cost : Int32
    getter swap : Array(Int32)?

    def initialize(@ptag, @cost = 10, @swap = nil)
    end
  end

  class Trie
    alias Suff = Hash(Int32, Trie)

    property rule : Rule?
    property suff : Suff? = nil

    def [](ptag : Int32) : Trie
      suff = @suff ||= Suff.new
      suff[ptag] ||= Trie.new
    end

    @[AlwaysInline]
    def []?(ptag : Int32) : Trie?
      @suff.try(&.[ptag]?)
    end
  end

  RULE_TRIE = Trie.new

  PTAG_USED = Set(Int32).new

  def get_rule(ptag : Int32)
    RULE_TRIE[ptag]?
  end

  def add_rule(input : RawRule)
    trie = RULE_TRIE

    input.rule.each do |ptag_str|
      ptag = PosTag.map_tag(ptag_str)
      PTAG_USED << ptag
      trie = trie[ptag]
    end

    swap = input.swap.try(&.map!(&.- 1))

    if input.ptag.starts_with?('$')
      ptag = -input.ptag[1..].to_i
    else
      ptag = PosTag.map_tag(input.ptag)
    end

    trie.rule = Rule.new(ptag, swap: swap, cost: input.cost)
  end

  files = Dir.glob("var/cvmtl/rules/**/*.yml")

  files.each do |file|
    File.open(file, "r") do |io|
      Array(RawRule).from_yaml(io).each { |rule| add_rule(rule) }
    end
  rescue err
    Log.error(exception: err) { file }
  end

  # PosTag::ROLE_MAP.each_value do |ptags|
  #   ptags.select! { |x| PTAG_USED.includes?(x) }
  # end

  # PosTag::ROLE_MAP.reject! { |_, v| v.empty? }
end
