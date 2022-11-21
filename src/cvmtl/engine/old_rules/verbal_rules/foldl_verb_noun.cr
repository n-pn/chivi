module MT::Rules
  def foldl_verb_noun!(verb : MtNode, noun : MtNode)
    head = foldl_noun_full!(noun)

    case head
    when SubjPred
      head.tap(&.add_verb(verb))
    when VerbExpr
      VerbPair.new(head, verb)
    when .prep_form?
      foldl_verb_prep!(verb, prep_form: head)
    when .all_nouns?
      SubjPred.new(head, verb, tag: MtlTag::SubjVerb)
    else
      raise "unsupported #{head.inspect} #{head.class}"
    end
  end
end
