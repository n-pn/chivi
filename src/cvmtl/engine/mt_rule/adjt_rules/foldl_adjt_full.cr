module MT::Rules
  # join adjective to larger non-adjectival structures
  def foldl_adjt_full!(adjt : MtNode) : MtNode
    adjt = foldl_adjt_join!(adjt)
    prev = adjt.prev
    prev = fix_mixedpos!(prev) if prev.is_a?(MonoNode) && prev.mixedpos?

    case prev
    when .noun_words?
      foldl_adjt_noun!(adjt, noun: prev)
    else
      # TODO: join adjt with other type

      adjt
    end
  end

  def foldl_adjt_noun!(adjt : MtNode, noun : MtNode)
    prev = foldl_noun_full!(noun)

    case prev
    when .noun_words?
      PairNode.new(prev, adjt, MtlTag::SubjAdjt, MtlPos::MaybeModi)
    when .prep_form?
      join_prep_form!(tail: adjt, prep_form: prev.as(PairNode))
    else
      Log.info { "unhandled: #{prev}" }
      adjt
    end
  end
end
