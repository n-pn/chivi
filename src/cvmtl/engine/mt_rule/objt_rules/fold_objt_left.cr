module MT::Core
  def fold_objt_left!(objt : MtNode, prev = objt.prev)
    prev = fix_mixedpos!(prev) if prev.mixedpos?

    case prev
    when .preposes?
      fold_objt_prep!(objt: objt, prep: prev.as(MonoNode))
    when .verbal_words?
      fold_objt_verb!(objt: objt, verb: prev)
    when .maybe_cmpl?
      prev = fold_vcompl!(prev)
      fold_objt_verb!(objt: objt, verb: prev)
    else
      objt
    end
  end
end
