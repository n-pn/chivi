module MT::Rules
  def fold_verb_noun!(verb : MtNode, noun : MtNode)
    head = fold_noun!(noun)

    case head
    when SubjPred
      head.tap(&.add_verb(verb))
    when VerbCons
      VerbPair.new(head, verb)
    when .prep_form?
      join_prep_form!(verb, prep_form: head)
    when .noun_words?
      SubjPred.new(head, verb, tag: MtlTag::SubjVerb)
    else
      raise "unsupported #{head.inspect} #{head.class}"
    end
  end
end
