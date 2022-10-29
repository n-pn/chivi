module MT::Rules
  def foldl_objt_verb!(objt : MtNode, verb : MtNode)
    head = foldl_verb_full!(verb)

    case head
    when VerbExpr
      head.tap(&.add_objt(objt))
    when SubjPred
      head.tap(&.add_objt(objt))
    when .verbal_words?
      VerbExpr.new(verb).tap(&.add_objt(objt))
    else
      Log.info { "unsupported #{head.class}: #{head.inspect}" }
      objt
    end
  end
end
