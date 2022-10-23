module MT::Core
  def fold_suffix!(node : MtNode, prev = node.prev)
    node
  end

  def fold_suffix!(node : MonoNode, prev = node.prev)
    return node unless prev.content_words?

    case node
    when .suf_men5?
      node.val = "các"
      tag = MtlTag::Nword
      pos = MtlPos.flags(Object, Ktetic, Plural)
      node = PairNode.new(prev, node, tag, pos, flip: true)

      fold_objt_left!(node)
    when .suf_xing?
      tag, pos = PosTag::Nattr
      PairNode.new(prev, node, tag, pos, flip: true)
    when .suf_time?
      node.fix_val!
      prev = fold_left!(prev)
      tag = MtlTag::Texpr
      pos = MtlPos.flags(Object)
      PairNode.new(prev, node, tag, pos, flip: true)
    when .suf_verb?
      tag = MtlTag::Verb
      pos = MtlPos.flags(None)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      fold_verb!(node)
    when .suf_zhi?
      fold_suf_zhi!(node, prev)
    else
      Log.warn { "unhandled suffix: #{node}" }
      return node unless prev.common_nouns?

      tag, pos = PosTag::Nword
      node = PairNode.new(prev, node, tag, pos, flip: true)
      cons_noun!(node)
    end
  end

  def fold_suf_zhi!(node : MonoNode, prev : MtNode)
    prev = fold_left_uzhi!(prev)

    tag = node.maybe_adjt? ? MtlTag::Aform : MtlTag::Nform
    pos = node.pos

    PairNode.new(prev, node, tag, pos, flip: !node.at_tail?)
  end
end
