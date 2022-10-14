module MT::TlRule
  def fold_adjt_measure(adjt : MonoNode, succ = adjt.succ?)
    return unless succ

    if succ.numeral?
      succ = fuse_number!(succ)
      return fold!(adjt, succ, PosTag::Aform)
    end

    return unless succ.is_a?(MonoNode) && (tail = succ.succ?) && tail.numeral?
    return unless succ_val = PRE_NUM_APPROS[succ.key]?
    succ.val = succ_val

    tail = fuse_number!(tail)
    fold!(adjt, tail, PosTag::Aform)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjts!(adjt : MtNode, prev : MtNode? = nil) : MtNode
    # if adjt.is_a?(MonoNode) && MEASURES.has_key?(adjt.key)
    #   fold_adjt_measure(adjt).try { |x| return x }
    # end

    while adjt.adjt_words?
      break unless succ = adjt.succ?
      # puts [adjt, succ, "fold_adjt"]
      # succ = heal_mixed!(succ, prev: adjt) if succ.polysemy?

      case succ.tag
      when .advb_words?
        if succ.key == "又"
          fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
        else
          break
        end
        # when .bond_word?
        # fold_adjt_junction!(succ, prev: adjt).try { |x| adjt = x } || break
        # when .adjt_words?
        #   adjt = fold!(adjt, succ, succ.tag)
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
            adjt = fold!(adjt, tail, PosTag::Aform)
          else
            adjt = fold!(adjt, succ, PosTag::Verb)
            return fold_verbs!(succ, prev: prev)
          end
        end

        break if prev || adjt.key.size > 1

        succ = fold_verbs!(succ)
        return fold!(adjt, succ, succ.tag, flip: true)
        # when .pt_le?
        #   break unless (tail = succ.succ?) && tail.key == "点"
        #   succ.val = ""
        #   adjt = fold!(adjt, tail.set!("chút"), PosTag::Aform)
        #   break
      when .pt_dep?
        break unless (tail = succ.succ?) && tail.key == "很"
        break if tail.succ?(&.boundary?.!)

        succ.val = ""
        adjt = fold!(adjt, tail.set!("cực kỳ"), PosTag::Aform)
        break
      when .pt_dev?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_adjt_ude2!(adjt, succ)
      when .pt_zhe?
        verb = fold!(adjt, succ.set!(""), PosTag::Verb)
        return fold_verbs!(verb, prev: prev)
      when .pt_zhi?
        adjt = fold_adj_adv!(adjt, prev)
        return fold_uzhi!(succ, adjt)
      when .adv_bu4?
        fold_adjt_adv_bu!(adjt, succ, prev).try { |x| return x } || break
      else
        break
      end

      break if succ == adjt.succ?
    end

    # TODO: combine with nouns
    fold_adj_adv!(adjt, prev)
  end
end
