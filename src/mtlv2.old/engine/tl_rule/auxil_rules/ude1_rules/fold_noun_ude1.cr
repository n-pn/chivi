module MtlV2::TlRule
  # def fold_verb_ude1!(verb : BaseNode, ude1 : BaseNode, right : BaseNode) : BaseNode
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

  def has_verb_after?(right : BaseNode) : Bool
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
