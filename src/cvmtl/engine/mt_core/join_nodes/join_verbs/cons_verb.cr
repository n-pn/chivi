require "./*"

module MT::Core
  def cons_verb!(verb : MtNode) : VerbCons
    verb = pair_verb!(verb)
    verb = VerbCons.new(verb) unless verb.is_a?(VerbCons)

    # join verb with adverbs
    while prev = verb.prev?
      case prev
      when .advb_words?
        verb.add_head(prev)
      when .maybe_advb?
        prev = prev.as(MonoNode)
        prev.as_advb!(prev.alt)
      else
        break
      end
    end

    return verb unless prev

    if prev.pt_dev?
      prev = join_udev!(prev)
      return verb unless prev.tag.dv_phrase?

      verb.add_head(prev)
      prev = verb.prev
    end

    return verb unless prev.time_words?

    advb = fold_time!(prev)
    advb.prep_form? ? join_prep_form!(verb, prep_form: advb) : verb.tap(&.add_head(advb))
  end
end
