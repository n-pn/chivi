module MT::Core
  def join_prep_form!(tail : MtNode, prep_form : MtNode)
    tail.pos |= MtlPos::MaybeAdjt
    tail = VerbCons.new(tail) unless tail.is_a?(VerbCons)
    tail.add_prep(prep_form)
    cons_verb!(tail)
  end
end
