require "./join_nouns/*"

module MT::Core
  # join noun modes:
  # - mode 0: join all adjacent nouns, resulting nouns
  # - mode 1: join nouns linked by junction nodes, resulting nouns
  # - mode 2: join nouns with modifiers, resulting nouns
  # - mode 3: join nouns with verbs/preposes, resulting prep_form or verb_object

  def join_noun!(noun : MtNode, prev = noun.prev, level = 0) : MtNode
    if prev.noun_words?
      noun = join_noun_1!(noun, prev)
      prev = noun.prev
    end

    level == 0 && prev ? join_noun_2!(noun) : noun
  end
end
