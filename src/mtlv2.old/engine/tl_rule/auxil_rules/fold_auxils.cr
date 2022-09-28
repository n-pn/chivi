module MtlV2::TlRule
  def fold_auxils!(node : BaseNode, mode = 1) : BaseNode
    case node.tag
    # when .ule?  then heal_ule!(node)  # 了
    when .ude1? then heal_ude1!(node) # 的
    when .ude2? then fold_ude2!(node) # 地
    when .ude3? then fold_ude3!(node) # 得
    when .usuo? then fold_usuo!(node) # 所
    else             node
    end
  end

  def heal_ude1!(ude1 : BaseNode) : BaseNode
    if (prev = ude1.prev?) && !prev.puncts?
      ude1.set!("")
    elsif (succ = ude1.succ?) && !succ.puncts?
      ude1.set!("")
    else
      ude1
    end
  end

  def fold_ude2!(node : BaseNode) : BaseNode
    fold_nouns!(node.set!("đất", PosTag::Noun))
  end

  def keep_ule?(prev : BaseNode, node : BaseNode, succ = node.succ?) : Bool
    return true unless succ
    return false if succ.popens?
    succ.ends? || succ.succ?(&.ule?) || false
  end
end