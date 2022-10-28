require "./*"

module MT::Core
  def fold_verb_cons!(verb : MtNode) : MtNode
    verb = pair_verb!(verb)
    # puts [verb, verb.prev?, "after pairing!"]
    verb = VerbCons.new(verb) unless verb.is_a?(VerbCons)

    # join verb with adverbs
    while prev = verb.prev
      case prev
      when .maybe_advb?
        prev.as(MonoNode).fix_val!
      else
        break unless prev.advb_words?
      end

      verb.add_advb(prev)
    end

    if prev.qtverb?
      prev = fold_quanti!(prev)
      return verb unless prev.nqverb?
    end

    if prev.nqverb? || (prev.nquants? && prev.maybe_advb?)
      verb.add_advb(prev)
      prev = verb.prev
    end

    # puts [verb, prev, verb.prev, "construct_verb"]

    if prev.ptcl_dev?
      prev = join_udev!(prev)
      return verb unless prev.tag.dv_phrase?

      verb.add_advb(prev)
      prev = verb.prev
    end

    return verb unless prev.time_words?

    advb = fold_time!(prev)
    advb.prep_form? ? join_prep_form!(verb, prep_form: advb) : verb.tap(&.add_advb(advb))
  end
end
