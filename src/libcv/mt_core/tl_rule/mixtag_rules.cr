module CV::TlRule
  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .adverbs?, .preposes?, .vmodals?, .vpro?
        return node.heal!(tag: PosTag::Verb)
      when .auxils?, .ude1?
        return node.heal!(tag: PosTag::Noun)
      when .nquants?
        if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
          return node.heal!(tag: PosTag::Noun)
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
      node.heal!(tag: PosTag::Noun)
    when .auxils?, .vdir?, .vshang?, .vxia?, .vcom?
      node.heal!(tag: PosTag::Verb)
    else
      node
    end
  end
end
