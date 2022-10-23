module MT::Core
  def fold_objt_verb!(objt : MtNode, verb : MtNode)
    head = verb.is_a?(MonoNode) ? fold_verb!(verb) : verb

    case head
    when VerbCons
      head.tap(&.add_objt(objt))
    when SubjPred
      head.tap(&.add_objt(objt))
    when .verb_words?
      VerbCons.new(verb).tap(&.add_objt(objt))
    else
      Log.info { "unsupported #{head.class}: #{head.inspect}" }
      objt
    end
  end
end
