module MT::Core
  def link_noun!(noun : MtNode, junc = noun.prev, left = junc.prev)
    case left
    when .noun_words?
      left = cons_noun!(left)
    when .pronouns?
      # FIXME: fold pronouns
    else
      return noun
    end

    tag = noun.tag == left.tag ? noun.tag : MtlTag::Nform
    pos = left.pos | noun.pos
    TrioNode.new(left, junc, noun, tag, pos)
  end
end
