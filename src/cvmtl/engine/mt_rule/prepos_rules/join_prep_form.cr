module MT::Core
  def join_prep_form!(tail : MtNode, prep_form : MtNode)
    tail = VerbCons.new(tail) unless tail.is_a?(VerbCons)
    tail.add_prep(prep_form)
    fold_verb!(tail)
  end
end
