module MT::Rules
  def join_prep_form!(tail : MtNode, prep_form : MtNode)
    tail = VerbExpr.new(tail) unless tail.is_a?(VerbExpr)
    tail.add_prep(prep_form)
    foldl_verb_full!(tail)
  end
end
