module CV::TlRule
  MEASURES = {
    "宽" => "rộng",
    "高" => "cao",
    "长" => "dài",
    "远" => "xa",
    "重" => "nặng",
  }

  def fold_measurement!(adjt : MtNode, succ = adjt.succ?)
    return unless succ
    return unless adjt_val = MEASURES[adjt.key]?
    return unless succ_val = PRE_NUM_APPROS[succ.key]?

    adjt.val = adjt_val
    succ.val = succ_val

    if (succ_2 = succ.succ?) && succ_2.numeric?
      succ_2 = fold_numbers!(succ_2)
      return fold!(adjt, succ_2, PosTag::Aform, dic: 7)
    end

    return fold!(adjt, succ, PosTag::VerbPhrase, dic: 7)
  end

  def fold_adjts!(node : MtNode, prev : MtNode? = nil) : MtNode
    if fold = fold_measurement!(node)
      return fold
    end

    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .aform?
        node = fold!(node, succ, PosTag::Aform, dic: 4)
      when .adjt?, .amorp?
        node = fold!(node, succ, PosTag::Adjt, dic: 4)
      when .ajno?
        return fold_swap!(node, succ, PosTag::Noun, dic: 7)
      when .noun?
        break unless node.key.size == 1 && !prev # or special case
        return fold_swap!(node, succ, PosTag::NounPhrase, dic: 4)
      when .vpro?, .verb?
        break unless node.key.size == 1 && !prev
        succ = fold_verbs!(succ)
        return fold_swap!(node, succ, PosTag::VerbPhrase, dic: 4)
      when .ule?
        break unless (succ_2 = succ.succ?) && succ_2.key == "点"
        succ.val = ""
        succ_2.val = "chút"
        return fold!(node, succ_2, PosTag::Aform, dic: 6)
      when .ude2?
        break unless succ_2 = succ.succ?
        break unless succ_2.verb? || succ_2.veno?

        succ_2 = fold_verbs!(succ_2)
        node = fold_adj_adv!(node, prev)

        succ.set!("mà")
        return fold!(node, succ_2, PosTag::VerbPhrase, dic: 5)
      when .uzhi?
        node = fold_adj_adv!(node, prev)
        return fold_uzhi!(succ, node)
      when .suf_nouns?
        node = fold_adj_adv!(node, prev)
        return fold_suf_noun!(node, succ)
      when .suf_verbs?
        node = fold_adj_adv!(node, prev)
        return fold_suf_verb!(node, succ)
      when .penum?, .concoord?
        break unless fold = fold_adjt_concoord!(succ, prev: node)
        node = fold
      when .adv_bu?
        break unless (succ_2 = succ.succ?)

        if prev && prev.adv_bu?
          return fold!(prev, succ_2, PosTag::Aform, dic: 4)
        elsif succ_2.key == node.key
          node = fold_adj_adv!(node, prev)
          succ.val = "hay"
          succ_2.val = "không"
          return fold!(node, succ_2, PosTag::Aform, dic: 4)
        end

        break
      else
        break
      end

      break if succ == node.succ?
    end

    # TODO: combine with nouns
    fold_adj_adv!(node, prev)
  end

  def fold_modifier!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    node = fold!(nega, node, node.tag, dic: 4) if nega

    return node unless succ = node.succ?
    succ.set!(PosTag::Noun) if succ.veno? || succ.ajno?
    fold_adjt_noun!(node, node.succ?)
  end

  def fold_adj_adv!(node : MtNode, prev = node.prev?)
    return node unless prev && prev.adverbs?
    fold_adverb_node!(prev, node, tag: PosTag::Aform, dic: 4)
  end

  def fold_adjt_noun!(adjt : MtNode, noun : MtNode?, ude1 : MtNode? = nil)
    return adjt if !noun

    noun = ude1 ? scan_noun!(noun) : fold_noun!(noun, mode: 1)
    return adjt unless noun.nouns?

    if ude1
      ude1.val = ""
      adjt = fold!(adjt, ude1, PosTag::DefnPhrase, 1)
    elsif adjt.adjt? && adjt.key.size == 1
      return adjt
    end

    if adjt.modifier? && do_not_swap?(adjt.key)
      noun = fold!(adjt, noun, noun.tag, dic: 7)
    else
      noun = fold_swap!(adjt, noun, noun.tag, dic: 6)
    end

    return noun unless (succ = noun.succ?) && noun.space?
    fold_swap!(noun, succ, PosTag::Space, dic: 3)
  end

  def do_not_swap?(key : String)
    {"原"}.includes?(key)
  end
end
