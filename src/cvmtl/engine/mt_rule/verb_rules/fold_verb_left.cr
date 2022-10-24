require "./*"

module MT::Core
  def fold_verb!(verb : MtNode)
    verb = fold_verb_cons!(verb)
    # puts [verb, verb.prev?]
    verb = link_verb!(verb)

    case prev = fold_left!(verb.prev)
    when .quantis?, .pro_dems?
      # FIXME: check pass verb object
      return verb if verb.succ.tag.pt_dep?
    when .noun_words?, .pronouns?
      # OK
    when .verb_words?, .adjt_words?
      return verb unless verb.v_shi?
    when .prep_form?
      return join_prep_form!(verb, prev)
    else
      # TODO: add more cases
      # - adjt as subject
      return verb
    end

    SubjPred.new(prev, verb, tag: MtlTag::SubjVerb)
  end
end
