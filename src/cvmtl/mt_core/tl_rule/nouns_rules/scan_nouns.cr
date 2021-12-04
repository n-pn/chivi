module CV::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not combine verb with object
  def scan_noun!(head : MtNode, mode = 0, prev : MtNode? = nil)
    # puts ["scan_noun", head, mode]

    case head
    when .uniques?
      head = heal_uniques!(head)
    when .pronouns?
      head = fold_pronouns!(head)
    when .popens?
      head = fold_quoted!(head)
      head = fold_noun!(head) if head.nouns?
    when .adjts?, .modifier?
      head = head.ajno? ? fold_ajno!(head) : fold_adjts!(head)

      unless head.nouns? || !(succ = head.succ?)
        noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
        head = fold_adjt_noun!(head, noun, ude1)
      end
    when .numeric?
      head = fold_number!(head)
    when .adverbs?
      head = fold_adverbs!(head)
      head = fold_head_ude1_noun!(head) if head.adjts? || head.verbs?
    when .vmodal?
      if vmodal_is_noun?(head)
        head.tag = PosTag::Noun
      else
        head = heal_vmodal!(head)
        head = fold_head_ude1_noun!(head) if head.verbs?
      end
    when .verbs?
      head = head.veno? ? fold_veno!(head) : fold_verbs!(head)
      head = fold_head_ude1_noun!(head) if head.verbs?
    when .nouns?
      head = fold_noun!(head, mode: 1) # fold noun but do not consume penum
      head = head.nouns? ? head : scan_noun!(head)
    end

    if prev && prev.pro_dems? && head.nouns?
      head = fold_pro_dem_noun!(prev, head)
    end

    return fold_noun_space!(head) if head.center_noun?

    return head unless mode < 2 && head.verbs? && (succ = head.succ?) && !succ.ends?
    # FIXME: move this to fold_verb?
    succ = scan_noun!(succ)

    fold!(head, succ, PosTag::VerbObject, dic: 8)
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (succ = head.succ?) && succ.ude1?
    succ.val = "" unless head.noun? || head.names?

    return head unless tail = succ.succ?
    fold!(head, scan_noun!(tail), PosTag::NounPhrase, dic: 4, flip: true)
  end
end
