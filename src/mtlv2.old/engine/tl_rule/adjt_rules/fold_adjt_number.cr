module MT::TlRule
  # MEASURES = {
  #   "宽" => "rộng",
  #   "高" => "cao",
  #   "长" => "dài",
  #   "远" => "xa",
  #   "重" => "nặng",
  # }

  def fold_adjt_number!(adjt : MtNode, succ = adjt.succ)
    if val = PRE_NUM_APPROS[succ.key]?
      adjt = fold!(adjt, succ.set!(val), adjt.tag, dic: 2)
      return adjt unless succ = adjt.succ?
    end

    return fold_adjts!(adjt) unless succ.numeral?

    succ = fold_number!(succ)
    return adjt unless succ.nquants?

    adjt = fold!(adjt, succ, PosTag::AdjtPhrase, dic: 7)

    return adjt unless (ude1 = adjt.succ?) && ude1.pd_dep?
    return adjt if !(tail = ude1.succ?) || tail.punctuations?

    tail = fold_once!(tail)
    defn = fold!(adjt, ude1.set!(""), PosTag::DefnPhrase, dic: 4)

    noun = fold!(defn, tail, tail.tag, dic: 4, flip: true)
    fold_noun_after!(noun)
  end
end
