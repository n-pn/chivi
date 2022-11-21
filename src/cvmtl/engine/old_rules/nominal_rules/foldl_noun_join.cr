module MT::Rules
  def foldl_noun_join(noun : MtNode, junc = noun.prev, left = junc.prev)
    case left
    when .all_nouns?
      left = foldl_noun_base!(left)
    when .all_prons?
      # FIXME: fold pronouns
    else
      return unless left.object?
    end

    tag = noun.tag == left.tag ? noun.tag : MtlTag.new(:nmix)
    pos = left.pos | noun.pos
    TrioNode.new(left, junc, noun, tag, pos)
  end
end
