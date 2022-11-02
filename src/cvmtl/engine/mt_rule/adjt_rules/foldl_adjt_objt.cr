module MT::Rules
  def foldl_adjt_objt!(adjt : MtNode, objt : MtNode)
    head = objt.prev
    tail = adjt.succ

    tag, pos = PosTag.make(:subj_adjt)

    case head
    when .preposes?
      head = foldl_objt_prep!(objt: objt, prep: head.as(MonoNode))
      join_prep_form!(tail: adjt, prep_form: head.as(PairNode))
    else
      return adjt if tail.ptcl_dev? || tail.ptcl_deps?
      PairNode.new(objt, adjt, tag, pos)
    end
  end
end
