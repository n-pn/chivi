require "../mt_data"

module M2::MtRule
  extend self

  alias SoloRule = Proc(MtData, MtNode, Int32, Nil)
  alias PairRule = Proc(MtData, MtNode, MtNode, Int32, Nil)

  class RuleNode
    property rule : SoloRule? = nil
    getter hash = {} of String => PairRule
    forward_missing_to @hash
  end

  TRIE = {} of String => RuleNode

  def _add_rule(apos : String, rule : SoloRule)
    node = TRIE[apos] ||= RuleNode.new
    node.rule = rule
  end

  def _add_rule(apos : String, bpos : String, rule : PairRule)
    node = TRIE[apos] ||= RuleNode.new
    node[bpos] = rule
  end

  @[AlwaysInline]
  def get_node(xpos : String)
    TRIE[xpos]?
  end

  @[AlwaysInline]
  def get_rule(xpos)
    get_node(xpos).try(&.rule)
  end

  @[AlwaysInline]
  def get_rule(apos : String, bpos)
    get_node(xpos).try(&.[bpos])
  end
end
