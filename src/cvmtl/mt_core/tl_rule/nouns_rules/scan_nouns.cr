module CV::TlRule
  def scan_noun!(head : MtNode, mode = 0, prev : MtNode? = nil)
    case head
    when .uniques?
      head = heal_uniques!(head)
    when .nouns?
      head = fold_noun!(head, mode: 1) # fold noun but do not consume penum
      head = head.nouns? ? head : scan_noun!(head)
    when .numeric?
      head = fold_numbers!(head)
      return head unless !head.noun? && (succ = head.succ?) && !succ.ends?

      succ = scan_noun!(succ)
      head = succ.nouns? ? fold_nquant_noun!(head, succ) : head
    when .adverbs?
      head = fold_head_ude1_noun!(fold_adverbs!(head))
    when .verbs?
      head = fold_head_ude1_noun!(fold_verbs!(head))
    when .adjts?
      head = fold_head_ude1_noun!(fold_adjts!(head))
    when .modifier?
      return head unless succ = head.succ?

      case succ
      when .ude1?
        head = fold_head_ude1_noun!(head)
      else
        head = fold_swap!(head, scan_noun!(succ), PosTag::NounPhrase, dic: 4)
      end
    end

    if prev && prev.pro_dems? && head.nouns?
      head = fold_pro_dem_noun!(prev, head)
    end

    if head.center_noun?
      return head unless (succ = head.succ?) && succ.space?
      fold_swap!(head, succ, PosTag::Place, dic: 3)
    elsif head.verbs?
      return head unless (succ = head.succ?) && !succ.ends?
      # FIXME: move this to fold_verb?
      succ = scan_noun!(succ)
      fold!(head, succ, PosTag::VerbObject, dic: 8)
    else
      head
    end
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (succ = head.succ?) && succ.ude1?
    succ.val = "" unless head.noun? || head.names?

    return head unless tail = succ.succ?
    fold_swap!(head, scan_noun!(tail), PosTag::NounPhrase, dic: 4)
  end
end
