module CV::TlRule
  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .adverbs?, .preposes?, .vmodals?, .vdir?, .vpro?
        node.heal!(tag: PosTag::Verb)
      when .auxils?, .ude1?
        node.heal!(tag: PosTag::Noun)
      end
    end

    return node unless succ = node.succ?

    case succ
    when .puncts?
      return node.heal!
      tag = node.prev?(&.preposes?) ? PosTag::Verb : PosTag::Noun
      return node.heal!(tag: tag)
    when .suf_nouns?
      return node.heal!(tag: PosTag::Noun)
    when .auxils?
      return node.heal!(tag: PosTag::Verb)
    else
      node
    end
  end
end
