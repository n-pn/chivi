module CV::TlRule
  def fold_ude1!(node : MtNode, prev = node.prev?, succ = node.succ?) : MtNode
    return node unless prev

    puts [node, prev, succ]

    if succ && !succ.ends?
      succ = scan_noun!(succ)
      if succ.nouns?
        return fold_ude1_left!(succ, node)
      elsif prev.adjt? && succ.verbs?
        # handle adjt + ude1 + verb
        return fold!(node, succ, succ.tag, dic: 9)
      end
    end

    node.val = ""
    heal_ude!(node, prev)
  end

  def heal_ude!(node : MtNode, prev : MtNode) : MtNode
    case prev
    when .popens? then return node
    when .puncts? then return node.set!("đích")
    when .names?, .pro_per?
      prev.prev? do |x|
        return node if x.verbs? || x.preposes? || x.nouns? || x.pronouns?
      end
    else
      # TODO: handle verbs?, adjts?
      return node
    end

    node.val = "của"
    fold_swap!(prev, node, PosTag::DefnPhrase, dic: 8)
  end

  def fold_ude1_left!(node : MtNode, prev = node.prev) : MtNode
    return node unless prev_2 = prev.prev?

    prev.val = ""

    case prev_2
    when .ajad?
      prev_2.val = "thông thường" if prev_2.key == "一般"
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .adjts?
      if (prev_3 = prev_2.prev?) && prev_3.noun?
        prev_2 = fold!(prev_3, prev, PosTag::DefnPhrase, dic: 8)
      end

      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .veno?, .vintr?, .verb_object?,
         .time?, .place?, .space?,
         .pro_dem?, .modifier?,
         .defn_phrase?, .prep_phrase?
      prev_2 = fold!(prev_2, prev, PosTag::DefnPhrase, dic: 7)
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .numeric?
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .nouns?, .pro_per?
      return fold_noun_ude1!(prev_2, prev, node)
    when .verb?
      return node unless prev_3 = prev_2.prev?
      # puts [prev_3, prev_2]

      case prev_3.tag
      when .nouns?
        if (prev_4 = prev_3.prev?) && prev_4.pre_bei?
          head = fold!(prev_4, prev_2, PosTag::DefnPhrase, dic: 8)
        else
          head = fold!(prev_3, prev_2, PosTag::DefnPhrase, dic: 9)
        end
        fold_swap!(head, node, PosTag::NounPhrase, dic: 9)
      when .nquants?
        node = fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 8)
        fold!(prev_3, node, PosTag::NounPhrase, 3)
      else
        node
      end
    else
      node
    end
  end
end
