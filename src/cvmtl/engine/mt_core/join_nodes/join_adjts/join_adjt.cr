module MT::Core
  # join adjective to larger non-adjectival structures
  def join_adjt!(adjt : MtNode) : MtNode
    adjt = link_adjt!(adjt)
    prev = adjt.prev
    prev = fix_mixedpos!(prev) if prev.is_a?(MonoNode) && prev.mixedpos?

    case prev
    when .noun_words?
      join_adjt_noun!(adjt, noun: prev)
    else
      # TODO: join adjt with other type

      adjt
    end
  end

  def join_adjt_noun!(adjt : MtNode, noun : MtNode)
    prev = join_noun!(noun)

    case prev
    when .noun_words?
      PairNode.new(prev, adjt, MtlTag::SubjAdjt, MtlPos::MaybeAdjt)
    when .prep_form?
      join_prep_form!(tail: adjt, prep_form: prev.as(PairNode))
    else
      Log.info { "unhandled: #{prev}" }
      adjt
    end
  end
end
