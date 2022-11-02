module MT::Rules
  def foldl_suffix_full!(node : MtNode, prev = node.prev)
    return node if prev.unreal? || !node.is_a?(MonoNode)

    case node
    when .suf_men5?
      node.val = "các"
      tag, pos = PosTag.make(:noun)
      node = PairNode.new(prev, node, tag, pos, flip: true)

      foldl_objt_full!(node)
    when .suf_xing?
      tag, pos = PosTag.make(:nattr)
      PairNode.new(prev, node, tag, pos, flip: true)
    when .suf_time?
      node.fix_val!
      prev = foldl_once!(prev)
      tag, pos = PosTag.make(:timeword)
      node = PairNode.new(prev, node, tag, pos, flip: true)

      foldl_objt_full!(node)
    when .suf_verb?
      tag, pos = PosTag.make(:verb)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      foldl_verb_full!(node)
    when .suf_zhi?
      foldl_suf_zhi_full!(node, prev)
    when .suf_noun?
      tag, pos = PosTag.make(:noun)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      foldl_objt_full!(node)
    else
      # Log.warn { "unhandled suffix: #{node.inspect}" }
      return node unless prev.common_nouns?

      tag, pos = PosTag.make(:noun)
      node = PairNode.new(prev, node, tag, pos, flip: true)
      foldl_objt_full!(node)
    end
  end

  def foldl_suf_zhi_full!(node : MonoNode, prev : MtNode)
    prev = foldl_uzhi_base!(prev)

    tag = node.maybe_modi? ? MtlTag::Amod : MtlTag::Nmix
    pos = node.pos

    node = PairNode.new(prev, node, tag, pos, flip: !node.at_tail?)
    foldl_objt_full!(node)
  end
end
