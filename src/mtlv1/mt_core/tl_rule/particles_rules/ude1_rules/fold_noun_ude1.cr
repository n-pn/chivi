module CV::TlRule
  # def fold_noun_ude1!(noun : BaseNode, ude1 : BaseNode, right : BaseNode, mode = 0) : BaseNode
  #   case noun.tag
  #   when .time_words?, .nattr?,
  #        .posit?, .locat?,
  #        .numeral?, .vform? # , .prep_form?, .defn_phrase?
  #     ude1.val = ""
  #   when .pro_dem?
  #     if node = noun.find_by_key('样')
  #       ude1.val = ""
  #       node.val = "thế"
  #     else
  #       ude1.val = "của"
  #     end
  #   else
  #     ude1.val = "của"
  #   end

  #   noun = fold!(noun, ude1, PosTag::DcPhrase, dic: 3, flip: true)
  #   fold!(noun, right, PosTag::Nform, dic: 5, flip: true)
  # end

  # def fold_verb_ude1!(verb : BaseNode, ude1 : BaseNode, right : BaseNode) : BaseNode
  #   case right.key
  #   when "时候", "时", "打算"
  #     head = verb.try { |x| x if x.content? } || verb
  #     node = fold!(head, ude1, PosTag::DcPhrase)
  #     return fold!(node, right, PosTag::Nform, dic: 6, flip: true)
  #   end

  #   # puts [verb, noun, ude1, right]

  #   if verb.ends_with?('着')
  #     return fold_noun_ude1_noun!(noun, ude1, right)
  #   end

  #   case prev = verb.prev?
  #   when .nil?, .empty?
  #     head = verb if need_2_objects?(verb.key) || has_verb_after?(right)
  #   when .v_you?
  #     head = prev.content? ? prev : verb
  #   when .v_shi?
  #     head = verb unless has_verb_after?(right)
  #   when .comma?
  #     # TODO: check before comma?
  #   when .content?
  #     head = prev if need_2_objects?(verb.key)
  #   else
  #     unless is_linking_verb?(prev, right.succ?)
  #       head = verb if has_verb_after?(right)
  #     end
  #   end

  #   return fold_noun_ude1_noun!(noun, ude1, right) unless head

  #   node = fold!(head, ude1, PosTag::DcPhrase)
  #   fold!(node, right, PosTag::Nform, dic: 6, flip: true)
  # end

  def has_verb_after?(right : BaseNode) : Bool
    while right = right.succ?
      case right.tag
      when .pl_mark?, .mn_mark?, .verb_words?, .preposes?
        return true
      when .advb_words?, .comma?, .pro_ints?
        next
      else return false
      end
    end

    false
  end
end
