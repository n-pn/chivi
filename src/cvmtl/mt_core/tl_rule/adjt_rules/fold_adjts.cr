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
      succ_2 = fuse_number!(succ_2)
      return fold!(adjt, succ_2, PosTag::Aform, dic: 7)
    end

    return fold!(adjt, succ, PosTag::VerbPhrase, dic: 7)
  end

  def fold_adjts!(node : MtNode, prev : MtNode? = nil) : MtNode
    fold_measurement!(node).try { |x| return x }

    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .junction?
        fold_adjt_junction!(succ, prev: node).try { |x| node = x } || break
      when .aform?
        node = fold!(node, succ, PosTag::Aform, dic: 4)
      when .adjt?, .amorp?
        node = fold!(node, succ, PosTag::Adjt, dic: 4)
      when .ajno?
        return fold!(node, succ, PosTag::Noun, dic: 7, flip: true)
      when .veno?
        unless prev || node.key.size > 1
          succ = fold_nouns!(cast_noun!(succ))
          return fold!(node, succ, PosTag::NounPhrase, dic: 4, flip: true)
        else
          succ = cast_verb!(succ)
        end
      when .verb?
        break unless succ.key == "到"
        node = fold!(node, succ, PosTag::Adverb)
        return fold_adverbs!(node)
      when .nouns?
        node = fold_adj_adv!(node, prev)
        return fold_adjt_noun!(node, succ)
      when .vpro?, .verb?
        case succ.key
        when "到"
          node = fold!(node, succ, PosTag::Verb, dic: 6)
          return fold_verbs!(succ, prev: prev)
        end

        break if prev || node.key.size > 1

        succ = fold_verbs!(succ)
        return fold!(node, succ, succ.tag, dic: 4, flip: true)
      when .ule?
        break unless (succ_2 = succ.succ?) && succ_2.key == "点"
        succ.val = ""
        succ_2.val = "chút"
        return fold!(node, succ_2, PosTag::Aform, dic: 6)
      when .ude2?
        node = fold_adj_adv!(node, prev)
        return fold_adjt_ude2!(node, succ)
      when .uzhi?
        node = fold_adj_adv!(node, prev)
        return fold_uzhi!(succ, node)
      when .suf_noun?
        node = fold_adj_adv!(node, prev)
        return fold_suf_noun!(node, succ)
      when .suf_verb?
        node = fold_adj_adv!(node, prev)
        return fold_suf_verb!(node, succ)
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
    # puts [node, succ, nega].colorize.green

    node = fold!(nega, node, node.tag, dic: 4) if nega
    return node unless succ = node.succ?

    succ.set!(PosTag::Noun) if succ.veno? || succ.ajno?
    succ.noun? ? fold_adjt_noun!(node, succ) : node
  end

  def fold_adj_adv!(node : MtNode, prev = node.prev?)
    return node unless prev && prev.adverbs?
    fold_adverb_node!(prev, node, tag: PosTag::Aform, dic: 4)
  end
end
