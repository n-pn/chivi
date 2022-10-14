require "./join_nouns/*"

module MT::Core
  # join noun modes:
  # - mode 0: join all adjacent nouns, resulting nouns
  # - mode 1: join nouns linked by junction nodes, resulting nouns
  # - mode 2: join nouns with modifiers, resulting nouns
  # - mode 3: join nouns with verbs/preposes, resulting prep_form or verb_object

  def join_noun!(noun : MtNode, prev = noun.prev) : MtNode
    noun = pair_noun!(noun, prev)

    return noun unless prev = noun.prev?
    noun
    # level == 0 && prev ? join_noun_2!(noun) : noun
  end
end
