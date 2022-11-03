module MT::Rules
  def fixr_mixedpos!(head : MonoNode, prev = head.prev, succ = head.succ)
    if succ.is_a?(MonoNode) && succ.mixedpos?
      succ = fixr_mixedpos!(head: succ, prev: head)
    end

    case head
    when .hao_word?     then fix_hao_word!(head, succ)
    when .adjt_or_verb? then fixr_adjt_or_verb!(head, prev, succ)
    when .adjt_or_advb? then fixr_adjt_or_advb!(head, prev, succ)
    when .adjt_or_noun? then fixr_adjt_or_noun!(head, prev, succ)
    when .verb_or_advb? then fixr_verb_or_advb!(head, prev, succ)
    when .verb_or_noun? then fixr_verb_or_noun!(head, prev, succ)
    when .noun_or_advb? then fixr_noun_or_advb!(head, prev, succ)
    else                     head
    end
  end

  def fixr_adjt_or_verb!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case succ
    when .object?, .vdir?, .maybe_cmpl?
      return head.as_verb!(head.alt)
    end

    case prev
    when .maybe_auxi?, .verb_take_verb?
      return head.as_verb!(head.alt)
    end

    head.as_adjt!
  end

  def fixr_adjt_or_advb!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case succ
    when .verbal_words?, .preposes?
      head.as_advb!(head.alt)
    when .advb_words?
      succ.succ?(&.adjt_words?) ? head.as_adjt! : head.as_advb!(head.alt)
    else
      head.as_adjt!
    end
  end

  def fixr_adjt_or_noun!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case prev
    when .advb_words?, .maybe_advb?
      return head.as_adjt!
    end

    case succ
    when .v_shi?
      return head.as_adjt!
    when .verbal_words?
      return head.as_noun!(head.alt)
    end

    head # to be check again in foldl
  end

  def fixr_noun_or_advb!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case succ
    when .common_verbs?, .preposes?, .adjt_words?
      head.as_advb!(head.alt)
    when .advb_words?, .maybe_advb?
      head # to be check again in foldl
    else
      head.as_noun!
    end
  end

  def fixr_verb_or_advb!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case succ
    when .maybe_advb?
      head
    when .verbal_words?, .preposes?, .advb_words?, .adjt_words?
      head.as_advb!(head.alt)
    else
      head.as_verb!
    end
  end

  def fixr_verb_or_noun!(head : MonoNode, prev : MtNode, succ : MtNode) : MonoNode
    case succ
    when .aspect_marker?, .vdir?
      return head.as_verb!
    when .verbal_words?, .adjt_words?
      return head.as_noun!(head.alt)
    end

    case prev
    when .advb_words?, .maybe_auxi?
      return head.as_verb!
    end

    head
  end
end
