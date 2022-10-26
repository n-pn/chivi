module MT::Core
  def fold_suffix!(node : MtNode, prev = node.prev)
    node
  end

  def fold_suffix!(node : MonoNode, prev = node.prev)
    return node if prev.unreal?

    case node
    when .suf_men5?
      node.val = "các"
      tag, pos = PosTag.make(:noun)
      node = PairNode.new(prev, node, tag, pos, flip: true)

      fold_objt_left!(node)
    when .suf_xing?
      tag, pos = PosTag.make(:nattr)
      PairNode.new(prev, node, tag, pos, flip: true)
    when .suf_time?
      node.fix_val!
      prev = fold_left!(prev)
      tag, pos = PosTag.make(:timeword)
      node = PairNode.new(prev, node, tag, pos, flip: true)

      fold_objt_left!(node)
    when .suf_verb?
      tag, pos = PosTag.make(:verb)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      fold_verb!(node)
    when .suf_zhi?
      fold_suf_zhi!(node, prev)
    else
      Log.warn { "unhandled suffix: #{node}" }
      return node unless prev.common_nouns?

      tag, pos = PosTag.make(:noun)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      fold_objt_left!(node)

      # cons_noun!(node)
    end
  end

  def fold_suf_zhi!(node : MonoNode, prev : MtNode)
    prev = fold_left_uzhi!(prev)

    tag = node.maybe_modi? ? MtlTag::Amod : MtlTag::Nmix
    pos = node.pos

    node = PairNode.new(prev, node, tag, pos, flip: !node.at_tail?)
    fold_objt_left!(node)
  end
end
