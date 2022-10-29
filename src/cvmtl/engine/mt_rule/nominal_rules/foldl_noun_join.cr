module MT::Rules
  def foldr_noun_join!(noun : MtNode, junc = noun.prev, left = junc.prev)
    case left
    when .noun_words?
      left = foldl_noun_form!(left)
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
