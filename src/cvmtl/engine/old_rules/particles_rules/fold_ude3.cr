module MT::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verb_words? && succ.key != "到"
      node = fold!(node.set!("phải"), succ, succ.tag)
    else
      node.val = "được"
    end

    fold_verbs!(node)
  end

  def fold_adverb_ude3!(node : MtNode, succ : MtNode) : MtNode
    case tail = succ.succ?
    when .nil?
      fold!(node, succ.set!("phải"), PosTag::DrPhrase)
    when .key_is?("住")
      succ.val = ""
      node.as_verb!(nil) if node.is_a?(MonoNode)
      fold!(node, tail.set!("nổi"), PosTag::Verb)
    when .verb_words?
      node = fold!(node, succ.set!("phải"), PosTag::DrPhrase)
      fold_verbs!(tail, prev: node)
    else
      # TODO: add case here
      fold!(node, succ.set!("phải"), PosTag::DrPhrase)
    end
  end

  def fold_verb_ude3!(node : MtNode, succ : MtNode) : MtNode
    return node unless tail = succ.succ?
    succ.val = ""

    case tail
    # when .prep_bi3?
    # tail = fold_compare_bi3!(tail)
    # fold!(node, tail, PosTag::Vobj)
    when .advb_words?
      tail = fold_adverbs!(tail)

      if tail.adjt_words?
        fold!(node, tail, PosTag.make(:amix))
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(node, tail, PosTag.make(:amix))
      elsif tail.verb_words?
        succ.set!("đến")
        fold!(node, tail, tail.tag)
      else
        node
      end
    when .adjt_words?
      fold!(node, tail, PosTag.make(:amix))
    when .verb_words?
      node = fold!(node, succ, PosTag::Verb)
      fold_verb_compl!(node, tail) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
