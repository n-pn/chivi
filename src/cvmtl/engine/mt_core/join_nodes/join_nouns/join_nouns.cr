require "./*"

module MT::Core
  # join noun modes:
  # - mode 0: join all adjacent nouns, resulting nouns
  # - mode 1: join nouns linked by junction nodes, resulting nouns
  # - mode 2: join nouns with modifiers, resulting nouns
  # - mode 3: join nouns with verbs/preposes, resulting prep_form or verb_object

  def join_noun!(noun : MtNode, prev = noun.prev) : MtNode
    while prev.common_nouns?
      noun = pair_noun!(noun, prev)
      prev = noun.prev
    end

    if prev.adjt_words?
      noun = PairNode.new(prev, noun, flip: !prev.at_head?)
      prev = noun.prev
    end

    noun = form_noun!(noun, prev)
    fold_noun!(noun)
  end
end
