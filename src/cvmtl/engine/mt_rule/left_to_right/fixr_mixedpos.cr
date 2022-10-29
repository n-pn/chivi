module MT::Rules::LTR
  def fixr_mixedpos!(head : MonoNode, prev = head.prev, succ = head.succ)
    case head
    when .maybe_verb? then fixr_maybe_verb!(head, prev, succ)
    else                   head
    end
  end

  def fixr_maybe_verb!(head, prev, succ)
    case maybe_verb_tag(head, prev, succ)
    when .nil?          then head
    when .noun_words?   then head.as_noun!
    when .advb_words?   then head.as_advb!(head.alt)
    when .verbal_words? then head.as_verb!
    else                     head
    end
  end

  def maybe_verb_tag(head, prev, succ)
    case succ
    when .aspect_marker?, .maybe_cmpl?
      return MtlTag::Verb
    when .verbal_words?, .adjt_words?
      return head.maybe_advb? ? MtlTag::Adverb : MtlTag::Noun
    end

    case prev
    when .advb_words?, .maybe_advb?, .maybe_auxi?
      MtlTag::Verb
    when .maybe_modi?, .amod?
      head.maybe_noun? ? MtlTag::Noun : head
    end
  end
end
