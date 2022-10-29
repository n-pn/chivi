module MT::Rules::LTR
  def fixr_qttemp!(node : MonoNode, prev = node.prev, succ = node.succ)
    case node
    when .qtcmpl_or_x?
      # word that can be verb complement quantifier only if before is a verb
      unless prev.numbers? && prev.prev? { |x| x.common_verbs? || x.object? && x.prev?(&.common_verbs?) }
        return as_not_quanti!(node)
      end

      node.tag, node.pos = PosTag.make(:qtcmpl)
    when .qtverb_or_x?
      unless succ.common_verbs? || succ.maybe_verb? || succ.preposes?
        return as_not_quanti!(node)
      end

      node.tag, node.pos = PosTag.make(:qtverb)
    when .qtnoun_or_x?
      return node unless succ.common_nouns?
      node.tag, node.pos = PosTag.make(:qtnoun)
    when .qttime_or_x?
      node.tag, node.pos = PosTag.map_quanti(node.key)
    else
      node.tag, node.pos = PosTag.map_quanti(node.key)
    end

    node
  end

  def as_not_quanti!(node : MonoNode)
    node.tag, node.pos = PosTag.not_quanti(node.key)
    node.tap(&.fix_val!)
  end
end
