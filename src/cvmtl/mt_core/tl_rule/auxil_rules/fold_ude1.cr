module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    return heal_ude!(ude1, prev) unless prev && succ && !(prev.ends?)

    ude1.set!("")

    if noun = scan_noun!(succ, mode: 3)
      node = fold_ude1_left!(ude1: ude1, left: prev, right: noun)
      return fold_noun_after!(node, succ)
    end

    if prev.adjt? && succ.verbs?
      # puts [prev, succ, ude1]
      # handle adjt + ude1 + verb
      fold!(prev, succ, succ.tag, dic: 9)
    elsif prev.verb? && succ.adjts?
      # ude3 => ude1 grammar error
      fold!(prev, succ, prev.tag, dic: 8)
    else
      heal_ude!(ude1, prev)
    end
  end

  def heal_ude!(ude1 : MtNode, prev : MtNode?) : MtNode
    case prev
    when .nil?    then return ude1.set!("đích")
    when .pstops? then return ude1.set!("")
    when .puncts? then return ude1.set!("đích")
    when .names?, .human?
      prev.prev?.try { |x| return ude1.set!("") if x.verb? || x.veno? || x.vead? }
    else return ude1.set!("")
    end
    # TODO: handle verbs?, adjts?

    fold!(prev, ude1.set!("của"), PosTag::DefnPhrase, dic: 6, flip: true)
  end

  # do not return left when fail to prevent infinity loop
  def fold_ude1_left!(ude1 : MtNode, left : MtNode, right : MtNode?, mode = 0) : MtNode
    return ude1 unless right

    if left.ajno?
      left.tag = PosTag::Adjt
    elsif left.pro_na1?
      left.val = "cái kia"
    elsif left.key == "所有"
      return fold!(left.set!("tất cả"), right, PosTag::NounPhrase, dic: 5)
    end

    # puts [left, right]

    case left
    when .nouns?, .pronouns?, .numeric?, .verb_clause?, .adjt_clause?
      fold_noun_ude1!(left, ude1: ude1, right: right, mode: mode)
    else
      left = fold!(left, ude1, PosTag::DefnPhrase, dic: 7)
      fold!(left, right, PosTag::NounPhrase, dic: 4, flip: true)
    end
  end
end
