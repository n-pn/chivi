module CV::TlRule
  def fold_noun_adjt!(noun : MtNode, adjt : MtNode)
    return noun unless noun.noun?

    adjt = adjt.adverbs? ? fold_adverbs!(adjt) : fold_adjts!(adjt)

    case succ = adjt.succ?
    when .nil? then noun
    when .ude1?, .junction?
      fold!(noun, adjt, PosTag::Aform, dic: 6)
    when .ude2?
      return noun unless (prev = noun.prev?) && (prev.subject? || prev.junction?)
      adjt = fold!(noun, adjt, PosTag::Aform, dic: 6)
      fold_adjt_ude2!(adjt, succ)
    else
      noun
    end
  end
end
