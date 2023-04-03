require "../mt_data"

# reference: https://www.cs.brandeis.edu/~clp/ctb/parseguide.3rd.ch.pdf

module M2::MtRule
  extend self

  alias SoloRule = Proc(MtData, MtNode, Int32, Nil)
  alias PairRule = Proc(MtData, MtNode, MtNode, Int32, Nil)

  class RuleNode
    property rule : SoloRule? = nil
    getter hash = {} of Symbol => PairRule
    forward_missing_to @hash
  end

  TRIE = {} of Symbol => RuleNode

  def _add_rule(pos1 : Symbol, rule : SoloRule)
    node = TRIE[pos1] ||= RuleNode.new
    node.rule = rule
  end

  def _add_rule(pos1 : Symbol, pos2 : Symbol, rule : PairRule)
    node = TRIE[pos1] ||= RuleNode.new
    node[pos2] = rule
  end

  @[AlwaysInline]
  def get_node(xpos : Symbol)
    TRIE[xpos]?
  end

  @[AlwaysInline]
  def get_rule(xpos)
    get_node(xpos).try(&.rule)
  end

  @[AlwaysInline]
  def get_rule(pos1 : Symbol, pos2 : Symbol)
    get_node(xpos).try(&.[pos2])
  end

  def add_node(root : MtData, node : MtNode, idx : Int32, apply_rule = true)
    return unless node = root.add_node(node, idx)
    return unless apply_rule && (rule_node = get_node(node.ptag))

    if rule = rule_node.rule
      rule.call(root, node, idx)
    end

    pair_rules = rule_node.hash
    return if pair_rules.empty?

    succ_nodes = root.all_nodes[idx &+ node.size]
    return if succ_nodes.empty?

    # pp pair_rules, succ_nodes

    if succ_nodes.size < pair_rules.size
      succ_nodes.each do |ptag, nodes|
        next unless pair_rule = pair_rules[ptag]?

        nodes.each_value do |succ|
          pair_rule.call(root, node, succ, idx)
        end
      end
    else
      pair_rules.each do |ptag, pair_rule|
        next unless nodes = succ_nodes[ptag]?

        nodes.each_value do |succ|
          pair_rule.call(root, node, succ, idx)
        end
      end
    end
  end

  macro def_rule(pos1)
    def _{{pos1.id}}(root : MtData, head : MtNode, idx : Int32)
      {{ yield }}
    end

    _add_rule({{pos1}}, ->_{{pos1.id}}(MtData, MtNode, Int32))
  end

  macro def_rule(pos1, pos2)
    def _{{pos1.id}}__{{pos2.id}}(root : MtData, head : MtNode, secd : MtNode, idx : Int32)
      {{ yield }}
    end

    _add_rule({{pos1}}, {{pos2}}, ->_{{pos1.id}}__{{pos2.id}}(MtData, MtNode, MtNode, Int32))
  end

  macro copy_rule(pos1, rule_name)
    _add_rule({{pos1}}, ->_{{rule_name.id}}(MtData, MtNode, Int32))
  end

  macro copy_rule(pos1, pos2, rule_name)
    _add_rule({{pos1}}, {{pos2}}, ->_{{rule_name.id}}(MtData, MtNode, MtNode, Int32))
  end
end
