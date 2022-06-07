module CV::MtlV2::TlRule
  def fold_usuo!(usuo : MtNode)
    case succ = usuo.succ?
    when .nil? then usuo
    when .veno?
      verb = fold!(usuo.set!("chỗ"), MtDict.fix_verb!(succ), succ.tag, dic: 6)
      fold_verbs!(verb)
    when .verbal?
      verb = fold!(usuo.set!("chỗ"), succ, succ.tag, dic: 6)
      fold_verbs!(verb)
    else
      usuo
    end
  end
end
