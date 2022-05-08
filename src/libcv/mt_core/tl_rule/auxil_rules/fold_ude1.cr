module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    # ameba:disable Style/NegatedConditionsInUnless
    return heal_ude!(ude1, prev) unless prev && succ && !(prev.ends?)

    ude1.set!("")

    if (succ.pro_dems? || succ.pro_na2?) && (tail = succ.succ?)
      right = fold_pro_dems!(succ, tail)
    else
      right = scan_noun!(succ, mode: 3)
    end

    if right
      node = fold_ude1_left!(ude1: ude1, left: prev, right: right)
      return fold_noun_after!(node)
    end

    succ = ude1.succ # added as counter measure when succ get changed in scan_noun
    fix_ude1_errors!(ude1, prev, succ)
  end

  def fix_ude1_errors!(ude1 : MtNode, prev : MtNode, succ : MtNode)
    if succ.verbs? && prev.adjts? || prev.adverbs? || prev.verb?
      # ude1 as ude2 grammar error
      # puts [prev, succ, ude1]
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
      case right.key
      when "时"
        right.val = "khi"
        tag = PosTag::Time
      when "时候"
        right.val = "lúc"
        tag = PosTag::Time
      when "时间"
        right.val = "thời gian"
        tag = PosTag::Time
      else
        tag = PosTag::NounPhrase
      end

      left = fold!(left, ude1, PosTag::DefnPhrase, dic: 7)
      fold!(left, right, tag: tag, dic: 6, flip: true)
    end
  end
end
