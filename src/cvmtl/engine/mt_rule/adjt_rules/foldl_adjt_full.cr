module MT::Rules
  # join adjective to larger non-adjectival structures
  def foldl_adjt_full!(adjt : MtNode) : MtNode
    adjt = foldl_adjt_join!(adjt)
    prev = adjt.prev
    prev = fix_mixedpos!(prev) if prev.is_a?(MonoNode) && prev.mixedpos?

    case prev
    when .all_nouns?
      foldl_adjt_noun!(adjt, noun: prev)
    when .object?
      foldl_adjt_objt!(adjt, objt: prev)
    else
      # TODO: join adjt with other type
      adjt
    end
  end
end
