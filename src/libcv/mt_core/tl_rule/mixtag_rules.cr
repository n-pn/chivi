module CV::TlRule
  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .auxils?
        return node.heal!(PosTag::Noun)
      when .adverbs?, .preposes?, .vmodals?, .vpro?
        return node.heal!(PosTag::Verb)
      when .nquants?
        if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
          return node.heal!(PosTag::Noun)
        end
      end
    end

    return node unless succ = node.succ?

    case succ
    when .puncts?
      # tag = node.prev?(&.preposes?) ? PosTag::Verb : PosTag::Noun
      # node.heal!(tag: tag)
      node
    when .suf_nouns?
      node.heal!(PosTag::Noun)
    when .auxils?, .vdir?
      node.heal!(PosTag::Verb)
    else
      node
    end
  end
end
