module MT::Core
  def link_noun!(noun : MtNode, junc = noun.prev, left = junc.prev)
    case left
    when .noun_words?
      left = make_noun_cons!(left)
    when .all_prons?
      # FIXME: fold pronouns
    else
      return noun
    end

    tag = noun.tag == left.tag ? noun.tag : MtlTag.new(:nmix)
    pos = left.pos | noun.pos
    TrioNode.new(left, junc, noun, tag, pos)
  end
end
