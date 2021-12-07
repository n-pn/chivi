module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    return heal_ude!(ude1, prev) unless prev && succ
    ude1.set!("")

    if noun = scan_noun!(succ, mode: 3)
      return fold_ude1_left!(prev, ude1, noun)
    else
      succ = ude1.succ
    end

    if prev.adjt? && succ.verbs?
      # puts [prev, succ, ude1]
      # handle adjt + ude1 + verb
      fold!(prev, succ, succ.tag, dic: 9)
    elsif prev.verb? && succ.adjts?
      # ude3 => ude1 grammar error
      fold!(prev, succ, prev.tag, dic: 8)
    else
      # puts [ude1, prev, succ, ude1.idx, "here?"]
      ude1
    end
  end

  def heal_ude!(ude1 : MtNode, prev : MtNode?) : MtNode
    case prev
    when .nil?    then return ude1.set!("của")
    when .popens? then return ude1.set!("")
    when .puncts? then return ude1.set!("đích")
    when .names?, .pro_per?
      prev.prev? do |x|
        return ude1.set!("") if x.verbs? || x.preposes? # || x.nouns? || x.pronouns?
      end
      # TODO: handle verbs?, adjts?
    else return ude1.set!("")
    end

    ude1.val = "của"
    fold!(prev, ude1, PosTag::DefnPhrase, dic: 6, flip: true)
  end

  # do not return left when fail to prevent infinity loop
  def fold_ude1_left!(left : MtNode, ude1 : MtNode, right : MtNode?, mode = 0) : MtNode
    return ude1 unless right

    if left.ajno?
      left.tag = PosTag::Adjt
    elsif left.pro_na1?
      left.val = "cái kia"
    end

    case left
    when .nouns?, .pronouns?, .numeric?
      fold_noun_ude1!(left, ude1: ude1, right: right, mode: mode)
    when .verb?, .verb_phrase?
      fold_verb_ude1!(left, ude1: ude1, right: right, mode: mode)
    else
      left = fold!(left, ude1, PosTag::DefnPhrase, dic: 7)
      fold!(left, right, PosTag::NounPhrase, dic: 4, flip: true)
    end
  end
end
