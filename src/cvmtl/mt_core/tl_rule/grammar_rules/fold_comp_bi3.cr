module CV::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless noun = scan_noun!(succ, mode: mode)

    unless (succ = scan_adjt!(noun.succ?)) && (succ.maybe_adjt? || succ.verb_object?)
      return fold!(prepos, noun, PosTag::PrepPhrase, dic: 2)
    end

    if prepos.pre_bi3?
      adverb = fold!(prepos.set!("hơn"), noun, PosTag::Adverb, dic: 8)
      phrase = fold!(adverb, succ, PosTag::Aform, dic: 7, flip: true)
    else # handle 不比
      head = MtNode.new("不", "không", PosTag::AdvBu, 1, prepos.idx)
      tail = MtNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)
      head.fix_prev!(prepos.prev?)
      tail.fix_succ!(prepos.succ?)
      head.fix_succ!(tail)

      adverb = fold!(tail, noun, PosTag::Adverb, dic: 8)
      fold = fold!(adverb, succ, PosTag::Aform, dic: 7, flip: true)
      phrase = fold!(head, fold, PosTag::Aform, dic: 0)
    end

    return phrase unless (succ = phrase.succ?) && (succ.ude1? || succ.ude3?)
    return phrase unless (tail = succ.succ?) && tail.key == "多"

    succ.val = ""
    fold!(phrase, tail, PosTag::Unkn, dic: 0)
  end
end
