module MT::TlRule
  def fold_adjt_measure(adjt : MonoNode, succ = adjt.succ?)
    return unless succ

    if succ.numeral?
      succ = fuse_number!(succ)
      return fold!(adjt, succ, MapTag::Aform)
    end

    return unless succ.is_a?(MonoNode) && (tail = succ.succ?) && tail.numeral?
    return unless succ_val = PRE_NUM_APPROS[succ.key]?
    succ.val = succ_val

    tail = fuse_number!(tail)
    fold!(adjt, tail, MapTag::Aform)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjts!(adjt : BaseNode, prev : BaseNode? = nil) : BaseNode
    if adjt.is_a?(MonoNode) && MEASURES.has_key?(adjt.key)
      fold_adjt_measure(adjt).try { |x| return x }
    end

    while adjt.adjt_words?
      break unless succ = adjt.succ?
      # puts [adjt, succ, "fold_adjt"]
      succ = heal_mixed!(succ, prev: adjt) if succ.polysemy?

      case succ.tag
      when .advb_words?
        if succ.key == "又"
          fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
        else
          break
        end
      when .bond_word?
        fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
      when .adjt_words?
        adjt = fold!(adjt, succ, succ.tag)
      when .vdir?
        adjt.as_verb! if adjt.is_a?(MonoNode)
        return fold_verbs!(adjt)
      when .noun_words?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_noun!(adjt, succ)
      when .vpro?, .verb?
        case succ.key
        when "到"
          if (tail = succ.succ?) && tail.adjt_words?
            adjt = fold!(adjt, tail, MapTag::Aform)
          else
            adjt = fold!(adjt, succ, MapTag::Verb)
            return fold_verbs!(succ, prev: prev)
          end
        end

        break if prev || adjt.key.size > 1

        succ = fold_verbs!(succ)
        return fold!(adjt, succ, succ.tag, flip: true)
        # when .pt_le?
        #   break unless (tail = succ.succ?) && tail.key == "点"
        #   succ.val = ""
        #   adjt = fold!(adjt, tail.set!("chút"), MapTag::Aform)
        #   break
      when .pt_dep?
        break unless (tail = succ.succ?) && tail.key == "很"
        break if tail.succ?(&.boundary?.!)

        succ.val = ""
        adjt = fold!(adjt, tail.set!("cực kỳ"), MapTag::Aform)
        break
      when .pt_dev?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_ude2!(adjt, succ)
      when .pt_zhe?
        verb = fold!(adjt, succ.set!(""), MapTag::Verb)
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

  def fold_amod_words?(node : BaseNode, succ = node.succ?, nega : BaseNode? = nil)
    # puts [node, succ, nega].colorize.green

    node = fold!(nega, node, node.tag) if nega
    return node if !(succ = node.succ?) || succ.boundary?

    if succ.is_a?(MonoNode) && succ.polysemy?
      succ = heal_mixed!(succ, prev: node)
    end

    succ.noun_words? ? fold_adjt_noun!(node, succ) : fold_adjts!(node)
  end

  def fold_adj_adv!(node : BaseNode, prev = node.prev?)
    return node unless prev && prev.advb_words?
    fold_adverb_node!(prev, node, tag: MapTag::Aform)
  end
end
