module MT::Rules
  def foldl_objt_full!(objt : MtNode, prev = objt.prev)
    prev = fix_mixedpos!(prev) if prev.mixedpos?
    # puts [objt, prev, "foldl_objt_full"]

    case prev
    when .preposes?
      foldl_objt_prep!(objt: objt, prep: prev.as(MonoNode))
    when .verbal_words?
      foldl_objt_verb!(objt: objt, verb: prev)
    else
      objt
    end
  end
end