module CV::TlRule
  def fold_noun_adjt!(noun : MtNode, adjt : MtNode)
    return noun if !noun.noun? || adjt.adj_hao? || noun.prev?(&.pre_bi3?)
    return noun unless (adjt = scan_adjt!(adjt)) && adjt.adjts?

    case succ = adjt.succ?
    when .nil? then noun
    when .junction?
      fold!(noun, adjt, PosTag::Aform, dic: 6)
    when .ude1?
      return noun if succ.succ?(&.verbs?)
      fold!(noun, adjt, PosTag::Aform, dic: 7)
    when .ude2?
      return noun unless (prev = noun.prev?) && (prev.subject? || prev.junction?)
      adjt = fold!(noun, adjt, PosTag::Aform, dic: 8)
      fold_adjt_ude2!(adjt, succ)
    else
      noun
    end
  end
end
