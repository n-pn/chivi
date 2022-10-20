require "./*"

module MT::Core
  def fold_verb!(verb : MtNode)
    verb = cons_verb!(verb)
    verb = link_verb!(verb)

    while prev = verb.prev?
      prev = fix_mixedpos!(prev) if prev.mixedpos?

      case prev
      when .noun_words?
        verb = fold_verb_noun!(verb: verb, noun: prev)
        verb.is_a?(VerbCons) ? next : return verb
      when .quantis?, .pro_dems?
        # do not combine if verb is a part of noun modifier
        # FIXME: check pass verb object
        break if verb.succ.tag.pt_dep?
      when .pro_pers?
        # FIXME: join pro_pers
        # prev = join_pro_per!(prev)
      else
        # TODO: add more cases
        # - adjt as subject
        break
      end

      # return verb object form if prev is subject

      return SubjPred.new(prev, verb, tag: MtlTag::SubjVerb)
    end

    verb
  end
end
