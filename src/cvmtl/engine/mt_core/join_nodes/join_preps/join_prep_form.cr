module MT::Core
  def join_prep_form!(tail : MtNode, prep_form : MtNode)
    tail.pos |= MtlPos::MaybeAdjt
    tail = VerbForm.new(tail) unless tail.is_a?(VerbForm)
    tail.add_head(prep_form)
    make_verb!(tail)
  end
end
