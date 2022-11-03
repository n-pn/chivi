module MT::Rules
  def foldl_adjt_noun!(adjt : MtNode, noun : MtNode)
    noun = foldl_noun_base!(noun)
    head = noun.prev
    tail = adjt.succ

    tag, pos = PosTag.make(:subj_adjt)

    case head
    when .all_nouns?, .all_prons?, .numerals?
      adjt = PairNode.new(noun, adjt, tag, pos)
      return adjt if tail.ptcl_dev? || tail.ptcl_deps?

      PairNode.new(head, adjt, tag, pos)
    when .preposes?
      head = foldl_objt_prep!(objt: noun, prep: head.as(MonoNode))
      foldl_verb_prep!(tail: adjt, prep_form: head.as(PairNode))
    else
      return adjt unless tail.ptcl_dev? || tail.ptcl_deps?
      PairNode.new(noun, adjt, tag, pos)
    end
  end
end
