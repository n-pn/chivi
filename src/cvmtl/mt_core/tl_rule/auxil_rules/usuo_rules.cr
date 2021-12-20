module CV::TlRule
  def fold_usuo!(usuo : MtNode)
    case succ = usuo.succ?
    when .nil? then usuo
    when .veno?
      verb = fold!(usuo.set!("chỗ"), cast_verb!(succ), succ.tag, dic: 6)
      fold_verbs!(verb)
    when .verbs?
      verb = fold!(usuo.set!("chỗ"), succ, succ.tag, dic: 6)
      fold_verbs!(verb)
    else
      usuo
    end
  end
end
