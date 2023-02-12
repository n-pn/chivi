module M1::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_adjt!(noun : MtNode, adjt : MtNode)
    return noun if !noun.noun? || adjt.adj_hao?
    return noun if noun.prev? { |x| x.ude1? || x.pre_bi3? }
    return noun unless (adjt = scan_adjt!(adjt)) && adjt.adjective?

    case succ = adjt.succ?
    when .nil? then noun
    when .junction?
      fold!(noun, adjt, PosTag::Aform, dic: 6)
    when .ude1?
      return noun if succ.succ? { |x| x.verbal? || x.ends? }
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
