module CV::TlRule
  def fold_noun_ude1!(noun : MtNode, ude1 : MtNode, right : MtNode, mode = 0) : MtNode
    if mode == 0 && (prev = noun.prev?) && prev.verbs?
      fold_verb_noun_ude1!(prev, noun, ude1, right)
    else
      # puts ["this!", mode]
      fold_noun_ude1_noun!(noun, ude1, right)
    end
  end

  def fold_noun_ude1_noun!(noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    if noun.times? || noun.place? || noun.space? # || noun.prep_phrase? || noun.defn_phrase?
      ude1.val = ""
    else
      ude1.val = "của"
    end

    noun = fold!(noun, ude1, PosTag::DefnPhrase, dic: 3, flip: true)
    fold!(noun, right, PosTag::NounPhrase, dic: 5, flip: true)
  end

  def fold_verb_noun_ude1!(verb : MtNode, noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    case right.key
    when "时候", "时"
      head = verb.try { |x| x if x.center_noun? } || verb
      node = fold!(head, ude1, PosTag::DefnPhrase)
      return fold!(node, right, PosTag::NounPhrase, dic: 6, flip: true)
    end

    # puts [verb, noun, ude1, right]

    if verb.ends_with?('着')
      return fold_noun_ude1_noun!(noun, ude1, right)
    end

    case prev = verb.prev?
    when .nil?, .none?
      head = verb if has_verb_after?(right)
    when .v_you?
      head = prev.center_noun? ? prev : verb
    when .v_shi?
      head = verb unless has_verb_after?(right)
    when .comma?
      # TODO: check before comma?
    when .center_noun?
      head = nil
    else
      unless is_linking_verb?(prev, right.succ?)
        head = verb if has_verb_after?(right)
      end
    end

    return fold_noun_ude1_noun!(noun, ude1, right) unless head

    node = fold!(head, ude1, PosTag::DefnPhrase)
    fold!(node, right, PosTag::NounPhrase, dic: 6, flip: true)
  end

  def has_verb_after?(right : MtNode) : Bool
    while right = right.succ?
      case right.tag
      when .plsgn?, .mnsgn?, .verbs?, .preposes?
        return true
      when .adverbs?, .comma?, .pro_ints?
        next
      else return false
      end
    end

    false
  end
end
