require "./*"

module MT::Rules
  def foldl_verb_expr!(verb : MtNode) : MtNode
    verb = foldl_verb_pair!(verb)
    # puts [verb, verb.prev?, "after pairing!"]
    verb = VerbExpr.new(verb) unless verb.is_a?(VerbExpr)

    # join verb with adverbs
    while prev = verb.prev
      # TODO: handle when adjt is not advb

      case prev
      when .adjt_words?, .maybe_adjt?, .advb_words?
        verb.add_advb(prev)
      else
        break
      end
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

    if prev.ptcl_dev? || (prev.ptcl_dep? && prev.prev?(&.adjt_words?))
      prev = foldl_udev_full!(prev)
      return verb unless prev.tag.dv_phrase?

      verb.add_advb(prev)
      prev = verb.prev
    end

    return verb unless prev.all_times?

    advb = foldl_time_full!(prev)
    advb.prep_form? ? foldl_verb_prep!(verb, prep_form: advb) : verb.tap(&.add_advb(advb))
  end
end
