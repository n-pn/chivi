module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_adjt!(noun : BaseNode, adjt : BaseNode)
    return noun if !noun.common_nouns? || adjt.wd_hao?
    return noun if noun.prev? { |x| x.pt_dep? || x.pre_bi3? }
    return noun unless (adjt = scan_adjt!(adjt)) && adjt.adjt_words?

    case succ = adjt.succ?
    when .nil? then noun
    when .bond_word?
      fold!(noun, adjt, MapTag::Aform)
    when .pt_dep?
      return noun if succ.succ? { |x| x.verb_words? || x.boundary? }
      fold!(noun, adjt, MapTag::Aform)
    when .pt_dev?
      return noun unless (prev = noun.prev?) && (prev.object? || prev.bond_word?)
      adjt = fold!(noun, adjt, MapTag::Aform)
      fold_adjt_ude2!(adjt, succ)
    else
      noun
    end
  end
end
