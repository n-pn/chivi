module MT::MTL
  def fold_noun!(base : MtNode, succ : Middot)
    return succ unless (tail = succ.succ?) && is_human_name?(head, tail)

    if base.is_a?(HumanForm)
      base.append!(succ)
    else
      HumanForm.new(base, succ)
    end
  end

  def fold_noun!(base : MtNode, succ : Nominal)
    NounPair.new(base, succ, flip: false)
  end

  def is_human_name?(head : MtNode, tail : MtNode)
    case tail
    when HumanName, AffilName then true
    else
      tail.succ?.is_a?(Middot) && (head.is_a?(HumanName) || head.is_a?(HumanForm))
    end
  end
end
