require "./*"

module MT::Core
  def fold_verb!(verb : MtNode)
    verb = make_verb!(verb)
    verb = link_verb!(verb)

    while prev = verb.prev?
      prev = fix_mixedpos!(prev) if prev.mixedpos?

      case prev
      when .noun_words?
        verb = fold_verb_noun!(verb: verb, noun: prev)
        verb.is_a?(VerbForm) ? next : return verb
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

      # return verb object form if
      return PairNode.new(prev, verb, tag: PosTag::SubjVerb)
    end

    verb
  end

  def fold_verb_noun!(verb : MtNode, noun : MtNode)
    noun = fold_noun!(noun)

    unless noun.prep_form?
      return PairNode.new(noun, verb, tag: PosTag::SubjVerb)
    end

    verb = VerbForm.new(verb) unless verb.is_a?(VerbForm)

    verb.add_head(noun)
    make_verb!(verb)
  end
end
