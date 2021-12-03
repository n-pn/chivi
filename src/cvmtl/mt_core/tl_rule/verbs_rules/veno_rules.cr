module CV::TlRule
  def fold_veno!(node : MtNode)
    node = heal_veno!(node)

    if node.noun?
      node.val = MTL::AS_NOUNS.fetch(node.key, node.val)
      node = fold_noun!(node)
      fold_noun_left!(node)
    else
      fold_verbs!(node)
    end
  end

  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .auxils?, .preposes?
        return node.set!(PosTag::Noun)
      when .adverbs?, .vmodals?, .vpro?
        return node.set!(PosTag::Verb)
        # when .numeric?
        #   if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
        #     return node.set!(PosTag::Noun)
        #   end
        # when .pro_dem?
        #   unless node.succ?(&.ude1?)
        #     return node.set!(PosTag::Noun)
        #   end
      end
    end

    return node unless succ = node.succ?

    case succ
    when .ends?
      node.set!(PosTag::Noun)
    when .auxils?, .vdir?
      node.set!(PosTag::Verb)
    else
      node
    end
  end
end
