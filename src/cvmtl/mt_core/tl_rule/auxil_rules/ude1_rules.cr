module CV::TlRule
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    return ude1 unless prev
    return heal_ude!(ude1, prev) unless succ && !(succ.ends?)

    ude1.set!("")

    if noun = scan_noun!(succ, mode: 2)
      fold_ude1_left!(right: noun, ude1: ude1, prev: prev)
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

  def fold_ude1_left!(right : MtNode, ude1 : MtNode, prev = ude1.prev?) : MtNode
    return ude1 unless prev

    case prev
    when .ajad?
      prev.val = "thông thường" if prev.key == "一般"
      fold!(prev, right, PosTag::NounPhrase, dic: 4, flip: true)
    when .veno?, .vintr?, .verb_object?,
         .time?, .place?, .space?,
         .pro_dem?, .modifier?,
         .defn_phrase?, .prep_phrase?, .unkn?
      prev = fold!(prev, ude1, PosTag::DefnPhrase, dic: 7)
      fold!(prev, right, PosTag::NounPhrase, dic: 4, flip: true)
    when .adjts?
      # if (prev_2 = prev.prev?) && prev_2.noun?
      #   prev = fold!(prev_2, prev, PosTag::DefnPhrase, dic: 8)
      # end

      fold!(prev, right, PosTag::NounPhrase, dic: 4, flip: true)
    when .numeric?
      fold!(prev, right, PosTag::NounPhrase, dic: 4, flip: true)
    when .nouns?, .pro_per?
      return fold_noun_ude1!(prev, ude1, right)
    when .verb?, .verb_phrase?
      return fold_verb_ude1!(prev, ude1, right)
    else
      right
    end
  end
end
