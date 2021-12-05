module CV::TlRule
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    return ude1 unless prev
    return heal_ude!(ude1, prev) unless succ && !(succ.ends?)

    ude1.set!("")

    if noun = scan_noun!(succ, mode: 2)
      fold_ude1_left!(prev, ude1: ude1, right: noun, mode: 1)
    elsif prev.adjt? && succ.verbs?
      # puts [prev, succ, ude1]
      # handle adjt + ude1 + verb
      fold!(prev, succ, succ.tag, dic: 9)
    elsif prev.verb? && succ.adjts?
      # ude3 => ude1 grammar error
      fold!(prev, succ, prev.tag, dic: 8)
    else
      ude1
    end
  end

  def heal_ude!(ude1 : MtNode, prev : MtNode) : MtNode
    case prev
    when .popens? then return ude1.set!("")
    when .puncts? then return ude1.set!("đích")
    when .names?, .pro_per?
      prev.prev? do |x|
        return ude1.set!("") if x.verbs? || x.preposes? # || x.nouns? || x.pronouns?
      end
    else
      # TODO: handle verbs?, adjts?
      return ude1.set!("")
    end

    ude1.val = "của"
    fold!(prev, ude1, PosTag::DefnPhrase, dic: 6, flip: true)
  end

  def fold_ude1_left!(left : MtNode, ude1 : MtNode, right : MtNode, mode = 0) : MtNode
    case left
    when .nouns?, .pro_per?
      fold_noun_ude1!(left, ude1: ude1, right: right, mode: mode)
    when .verb?, .verb_phrase?
      fold_verb_ude1!(left, ude1: ude1, right: right, mode: mode)
    else
      left = fold!(left, ude1, PosTag::DefnPhrase, dic: 7)
      fold!(left, right, PosTag::NounPhrase, dic: 4, flip: true)
    end
  end
end
