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

    if (succ_2 = succ.succ?) && succ_2.numeral?
      succ_2 = fuse_number!(succ_2)
      return fold!(adjt, succ_2, PosTag::Aform, dic: 7)
    end

    fold!(adjt, succ, PosTag::VerbPhrase, dic: 7)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjts!(adjt : MtNode, prev : MtNode? = nil) : MtNode
    fold_measurement!(adjt).try { |x| return x }

    while adjt.adjective?
      break unless succ = adjt.succ?

      case succ.tag
      when .adverb?
        if succ.key == "又"
          fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
        else
          break
        end
      when .junction?
        fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
      when .aform?
        adjt = fold!(adjt, succ, PosTag::Aform, dic: 4)
      when .adjt?
        adjt = fold!(adjt, succ, PosTag::Adjt, dic: 4)
      when .ajno?
        return fold!(adjt, succ, PosTag::Noun, dic: 7, flip: true)
      when .veno?
        if !prev && adjt.key.size == 1
          succ = MtDict.fix_verb!(succ)
        else
          succ = fold_nouns!(MtDict.fix_noun!(succ))
          return fold!(adjt, succ, PosTag::NounPhrase, dic: 5, flip: true)
        end
      when .vdir?
        return fold_verbs!(MtDict.fix_verb!(adjt))
      when .verb?
        break unless succ.key == "到"
        adjt = fold!(adjt, succ, PosTag::Adverb)
        return fold_adverbs!(adjt)
      when .nominal?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_noun!(adjt, succ)
      when .vpro?, .verb?
        case succ.key
        when "到"
          if (tail = succ.succ?) && tail.adjective?
            adjt = fold!(adjt, tail, PosTag::Aform, dic: 7)
          else
            adjt = fold!(adjt, succ, PosTag::Verb, dic: 6)
            return fold_verbs!(succ, prev: prev)
          end
        end

        break if prev || adjt.key.size > 1

        succ = fold_verbs!(succ)
        return fold!(adjt, succ, succ.tag, dic: 4, flip: true)
        # when .ule?
        #   break unless (tail = succ.succ?) && tail.key == "点"
        #   succ.val = ""
        #   adjt = fold!(adjt, tail.set!("chút"), PosTag::Aform, dic: 6)
        #   break
      when .ude1?
        break unless (tail = succ.succ?) && tail.key == "很"
        break if tail.succ?(&.ends?.!)

        succ.val = ""
        adjt = fold!(adjt, tail.set!("cực kỳ"), PosTag::Aform, dic: 4)
        break
      when .ude2?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_ude2!(adjt, succ)
      when .uzhe?
        verb = fold!(adjt, succ.set!(""), PosTag::Verb, dic: 6)
        return fold_verbs!(verb, prev: prev)
      when .uzhi?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_uzhi!(succ, adjt)
      when .suf_noun?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_suf_noun!(adjt, succ)
      when .suf_verb?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_suf_verb!(adjt, succ)
      when .adv_bu4?
        fold_adjt_adv_bu!(adjt, succ, prev).try { |x| return x } || break
      else
        break unless succ.key == "又"
        fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
      end

      break if succ == adjt.succ?
    end

    # TODO: combine with nouns
    fold_adj_adv!(adjt, prev)
  end

  def fold_modifier!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    # puts [node, succ, nega].colorize.green

    node = fold!(nega, node, node.tag, dic: 4) if nega
    return node unless succ = node.succ?

    MtDict.fix_noun!(succ) if succ.veno? || succ.ajno?
    # puts [node, succ]

    succ.nominal? ? fold_adjt_noun!(node, succ) : fold_adjts!(node)
  end

  def fold_adj_adv!(node : MtNode, prev = node.prev?)
    return node unless prev && prev.adverbial?
    fold_adverb_node!(prev, node, tag: PosTag::Aform, dic: 4)
  end
end
