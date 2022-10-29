module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_adjt!(noun : MtNode, adjt : MtNode)
    return noun if !noun.common_nouns? || adjt.wd_hao?
    return noun if noun.prev? { |x| x.ptcl_dep? || x.prep_bi3? }
    return noun unless (adjt = scan_adjt!(adjt)) && adjt.adjt_words?

    case succ = adjt.succ?
    when .nil? then noun
    when .join_word?
      fold!(noun, adjt, PosTag.make(:amix))
    when .ptcl_dep?
      return noun if succ.succ? { |x| x.verbal_words? || x.boundary? }
      fold!(noun, adjt, PosTag.make(:amix))
    when .ptcl_dev?
      return noun unless (prev = noun.prev?) && (prev.object? || prev.join_word?)
      adjt = fold!(noun, adjt, PosTag.make(:amix))
      fold_adjt_ude2!(adjt, succ)
    else
      noun
    end
  end
end
