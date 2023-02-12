module M1::TlRule
  def fold_noun_ude1!(noun : MtNode, ude1 : MtNode, right : MtNode, mode = 0) : MtNode
    case noun.tag
    when .ntime?, .nattr?,
         .posit?, .locat?,
         .numeral?, .verb_clause? # , .prep_clause?, .defn_phrase?
      ude1.val = ""
    when .pro_dem?
      if node = noun.find_by_key('样')
        ude1.val = ""
        node.val = "thế"
      else
        ude1.val = "của"
      end
    else
      ude1.val = "của"
    end

    noun = fold!(noun, ude1, PosTag::DefnPhrase, dic: 3, flip: true)
    fold!(noun, right, PosTag::NounPhrase, dic: 5, flip: true)
  end

  # def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, right : MtNode) : MtNode
  #   case right.key
  #   when "时候", "时", "打算"
  #     head = verb.try { |x| x if x.subject? } || verb
  #     node = fold!(head, ude1, PosTag::DefnPhrase)
  #     return fold!(node, right, PosTag::NounPhrase, dic: 6, flip: true)
  #   end

  #   # puts [verb, noun, ude1, right]

  #   if verb.ends_with?('着')
  #     return fold_noun_ude1_noun!(noun, ude1, right)
  #   end

  #   case prev = verb.prev?
  #   when .nil?, .none?
  #     head = verb if need_2_objects?(verb.key) || has_verb_after?(right)
  #   when .v_you?
  #     head = prev.subject? ? prev : verb
  #   when .v_shi?
  #     head = verb unless has_verb_after?(right)
  #   when .comma?
  #     # TODO: check before comma?
  #   when .subject?
  #     head = prev if need_2_objects?(verb.key)
  #   else
  #     unless is_linking_verb?(prev, right.succ?)
  #       head = verb if has_verb_after?(right)
  #     end
  #   end

  #   return fold_noun_ude1_noun!(noun, ude1, right) unless head

  #   node = fold!(head, ude1, PosTag::DefnPhrase)
  #   fold!(node, right, PosTag::NounPhrase, dic: 6, flip: true)
  # end

  def has_verb_after?(right : MtNode) : Bool
    while right = right.succ?
      case right.tag
      when .plsgn?, .mnsgn?, .verbal?, .preposes?
        return true
      when .adverbial?, .comma?, .pro_ints?
        next
      else return false
      end
    end

    false
  end
end
