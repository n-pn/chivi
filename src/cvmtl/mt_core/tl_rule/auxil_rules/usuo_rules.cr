module CV::TlRule
  def fold_usuo!(usuo : MtNode)
    case succ = usuo.succ?
    when .nil? then usuo
    when .verbs?
      verb = fold!(usuo, succ, succ.tag, dic: 6)
      fold_verbs!(verb)
    else
      usuo
    end
  end
end
