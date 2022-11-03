module MT::Rules
  def foldl_verb_prep!(tail : MtNode, prep_form : MtNode)
    tail = VerbExpr.new(tail) unless tail.is_a?(VerbExpr)
    tail.add_prep(prep_form)
    foldl_verb_full!(tail)
  end
end
