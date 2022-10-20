module MT::Core
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    head = verb.is_a?(MonoNode) ? fold_verb!(verb) : verb

    case head
    when VerbForm
      head.tap(&.add_objt(noun))
    when SubjPred
      head.tap(&.add_objt(noun))
    when .verb_words?
      VerbForm.new(verb).tap(&.add_objt(noun))
    else
      Log.info { "unsupported #{head.class}: #{head.inspect}" }
      noun
    end
  end
end
