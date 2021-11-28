module CV::TlRule
  def scan_noun!(head : MtNode, mode = 0)
    case head
    when .nphrase?, .verobj? then head
    when .uniques?           then heal_uniques!(head)
    when .nouns?
      head = fold_noun!(head, mode: 1) # fold noun but do not consume penum
      head.nouns? ? head : scan_noun!(head)
    when .numeric?
      head = fold_numbers!(head)
      return head unless !head.noun? && (succ = head.succ?) && !succ.ends?

      succ = scan_noun!(succ)
      succ.nouns? ? fold_nquant_noun!(head, succ) : head
    when .adverbs?
      fold_head_ude1_noun!(fold_adverbs!(head), succ.succ?)
    when .verbs?
      fold_head_ude1_noun!(fold_verbs!(head))
    when .adjts?
      fold_head_ude1_noun!(fold_adjst!(head))
    when .modifier?
      return head unless succ = head.succ?
      case succ
      when .ude1?
        fold_head_ude1_noun!(head)
      else
        fold_swap!(head, scan_noun!(succ), PosTag::Nphrase, dic: 4)
      end
    else
      head
    end
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (succ = head.succ?) && succ.ude1?
    succ.val = "" unless head.noun? || head.names?

    return head unless tail = succ.succ?
    fold_swap!(head, scan_noun!(tail), PosTag::Nphrase, dic: 4)
  end
end
