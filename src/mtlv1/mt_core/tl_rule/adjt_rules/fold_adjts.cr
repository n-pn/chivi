module CV::TlRule
  MEASURES = {
    "宽" => "rộng",
    "高" => "cao",
    "长" => "dài",
    "远" => "xa",
    "重" => "nặng",
  }

  def fold_adjt_measure(adjt : MtTerm, succ = adjt.succ?)
    return unless succ

    if succ.numeral?
      succ = fuse_number!(succ)
      return fold!(adjt, succ, PosTag::Aform, dic: 7)
    end

    return unless succ.is_a?(MtTerm) && (tail = succ.succ?) && tail.numeral?
    return unless succ_val = PRE_NUM_APPROS[succ.key]?
    succ.val = succ_val

    tail = fuse_number!(tail)
    fold!(adjt, tail, PosTag::Aform, dic: 7)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjts!(adjt : BaseNode, prev : BaseNode? = nil) : BaseNode
    if adjt.is_a?(MtTerm) && MEASURES.has_key?(adjt.key)
      fold_adjt_measure(adjt).try { |x| return x }
    end

    while adjt.adjts?
      break unless succ = adjt.succ?
      # puts [adjt, succ, "fold_adjt"]
      succ = heal_mixed!(succ, prev: adjt) if succ.polysemy?

      case succ.tag
      when .adverbs?
        if succ.key == "又"
          fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
        else
          break
        end
      when .bond_word?
        fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
      when .adjts?
        adjt = fold!(adjt, succ, succ.tag, dic: 4)
      when .vdir?
        adjt.as_verb! if adjt.is_a?(MtTerm)
        return fold_verbs!(adjt)
      when .nominal?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_noun!(adjt, succ)
      when .vpro?, .verb?
        case succ.key
        when "到"
          if (tail = succ.succ?) && tail.adjts?
            adjt = fold!(adjt, tail, PosTag::Aform, dic: 7)
          else
            adjt = fold!(adjt, succ, PosTag::Verb, dic: 6)
            return fold_verbs!(succ, prev: prev)
          end
        end

        break if prev || adjt.key.size > 1

        succ = fold_verbs!(succ)
        return fold!(adjt, succ, succ.tag, dic: 4, flip: true)
        # when .pt_le?
        #   break unless (tail = succ.succ?) && tail.key == "点"
        #   succ.val = ""
        #   adjt = fold!(adjt, tail.set!("chút"), PosTag::Aform, dic: 6)
        #   break
      when .pt_dep?
        break unless (tail = succ.succ?) && tail.key == "很"
        break if tail.succ?(&.boundary?.!)

        succ.val = ""
        adjt = fold!(adjt, tail.set!("cực kỳ"), PosTag::Aform, dic: 4)
        break
      when .pt_dev?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_ude2!(adjt, succ)
      when .pt_zhe?
        verb = fold!(adjt, succ.set!(""), PosTag::Verb, dic: 6)
        return fold_verbs!(verb, prev: prev)
      when .pt_zhi?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_uzhi!(succ, adjt)
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

  def fold_modis?(node : BaseNode, succ = node.succ?, nega : BaseNode? = nil)
    # puts [node, succ, nega].colorize.green

    node = fold!(nega, node, node.tag, dic: 4) if nega
    return node if !(succ = node.succ?) || succ.boundary?

    if succ.is_a?(MtTerm) && succ.polysemy?
      succ = heal_mixed!(succ, prev: node)
    end

    succ.nominal? ? fold_adjt_noun!(node, succ) : fold_adjts!(node)
  end

  def fold_adj_adv!(node : BaseNode, prev = node.prev?)
    return node unless prev && prev.advbial?
    fold_adverb_node!(prev, node, tag: PosTag::Aform, dic: 4)
  end
end
