require "./*"

module MT::Rules
  def foldl_verb_full!(verb : MtNode)
    # puts [verb, verb.prev?, "fold_verb"]

    fix_aspcmpl_val!(verb)
    verb = foldl_verb_expr!(verb)

    # puts [verb, verb.prev?]

    prev = verb.prev
    if prev.join_word?
      verb = foldl_verb_join!(verb, join: prev)
      prev = verb.prev
    end

    case prev = foldl_once!(verb.prev)
    when .quantis?, .dem_prons?
      # FIXME: check pass verb object
      return verb if verb.common_verbs? && verb.succ.tag.ptcl_dep?
    when .all_nouns?, .all_prons?
      # OK
    when .verbal_words?, .adjt_words?
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

  def fix_aspcmpl_val!(verb : MtNode) : Nil
    return if verb.succ? { |x| x.unreal? || x.boundary? } || !verb.verb_take_obj?

    while verb.is_a?(PairNode)
      tail = verb.tail

      if tail.aspect_marker?
        return tail.as(MonoNode).skipover!
      else
        verb = verb.head
      end
    end

    verb.val = verb.val.sub(/ rồi/, "") if verb.is_a?(MonoNode)
  end
end
