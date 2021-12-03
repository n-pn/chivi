module CV::TlRule
  def fold_ude1!(ude1 : MtNode, prev = ude1.prev?, succ = ude1.succ?) : MtNode
    ude1.val = ""
    return ude1 unless prev

    if succ && !succ.ends?
      succ = scan_noun!(succ)

      if succ.nouns? || succ.pronouns?
        return fold_ude1_left!(succ, ude1)
      elsif prev.adjt? && succ.verbs?
        # puts [prev, succ, ude1]
        # handle adjt + ude1 + verb
        return fold!(prev, succ, succ.tag, dic: 9)
      elsif prev.verb? && succ.adjts?
        # ude3 => ude1 grammar error
        return fold!(prev, succ, prev.tag, dic: 8)
      end
    end

    heal_ude!(ude1, prev)
  end

  def heal_ude!(ude1 : MtNode, prev : MtNode) : MtNode
    case prev
    when .popens? then return ude1
    when .puncts? then return ude1.set!("đích")
    when .names?, .pro_per?
      prev.prev? do |x|
        return ude1 if x.verbs? || x.preposes? || x.nouns? || x.pronouns?
      end
    else
      # TODO: handle verbs?, adjts?
      return ude1
    end

    ude1.val = "của"
    fold_swap!(prev, ude1, PosTag::DefnPhrase, dic: 8)
  end

  def fold_ude1_left!(right : MtNode, ude1 : MtNode) : MtNode
    return ude1 unless prev = ude1.prev?

    ude1.val = ""

    case prev
    when .ajad?
      prev.val = "thông thường" if prev.key == "一般"
      fold_swap!(prev, right, PosTag::NounPhrase, dic: 4)
    when .veno?, .vintr?, .verb_object?,
         .time?, .place?, .space?,
         .pro_dem?, .modifier?,
         .defn_phrase?, .prep_phrase?, .unkn?
      prev = fold!(prev, ude1, PosTag::DefnPhrase, dic: 7)

      fold_swap!(prev, right, PosTag::NounPhrase, dic: 4)
    when .adjts?
      # if (prev_2 = prev.prev?) && prev_2.noun?
      #   prev = fold!(prev_2, prev, PosTag::DefnPhrase, dic: 8)
      # end

      fold_swap!(prev, right, PosTag::NounPhrase, dic: 4)
    when .numeric?
      fold_swap!(prev, right, PosTag::NounPhrase, dic: 4)
    when .nouns?, .pro_per?
      return fold_noun_ude1!(prev, ude1, right)
    when .verb?
      return fold_verb_ude1!(prev, ude1, right)
    else
      right
    end
  end
end
