module CV::TlRule
  def scan_noun!(head : MtNode, mode = 0)
    case head
    when .noun_phrase?, .verobj? then head
    when .uniques?               then heal_uniques!(head)
    when .nouns?
      head = fold_noun!(head, mode: 1) # fold noun but do not consume penum
      head = head.nouns? ? head : scan_noun!(head)
    when .numeric?
      head = fold_numbers!(head)
      return head unless !head.noun? && (succ = head.succ?) && !succ.ends?

      succ = scan_noun!(succ)
      succ.nouns? ? fold_nquant_noun!(head, succ) : head
    when .adverbs?
      head = fold_head_ude1_noun!(fold_adverbs!(head))
    when .verbs?
      head = fold_head_ude1_noun!(fold_verbs!(head))
    when .adjts?
      head = fold_head_ude1_noun!(fold_adjts!(head))
    when .modifier?
      return head unless succ = head.succ?

      case succ
      when .ude1? then fold_head_ude1_noun!(head)
      else
        fold_swap!(head, scan_noun!(succ), PosTag::NounPhrase, dic: 4)
      end
    end

    return head unless head.nouns? && (succ = head.succ?) && succ.space?
    fold_swap!(head, succ, PosTag::Place, dic: 3)
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (succ = head.succ?) && succ.ude1?
    succ.val = "" unless head.noun? || head.names?

    return head unless tail = succ.succ?
    fold_swap!(head, scan_noun!(tail), PosTag::NounPhrase, dic: 4)
  end
end
