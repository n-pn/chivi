module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_adjt!(noun : BaseNode, adjt : BaseNode)
    return noun if !noun.noun? || adjt.adj_hao?
    return noun if noun.prev? { |x| x.pt_dep? || x.pre_bi3? }
    return noun unless (adjt = scan_adjt!(adjt)) && adjt.adjective?

    adjt = fold!(noun, adjt, PosTag::AdjtPhrase, dic: 6)
    fold_adjt_after!(adjt)
  end
end
