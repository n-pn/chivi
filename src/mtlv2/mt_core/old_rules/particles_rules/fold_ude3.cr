module MT::TlRule
  def heal_ude3!(node : BaseNode, succ = node.succ?) : BaseNode
    return node unless succ

    if succ.verb_words? && succ.key != "到"
      node = fold!(node.set!("phải"), succ, succ.tag, dic: 6)
    else
      node.val = "được"
    end

    fold_verbs!(node)
  end

  def fold_adverb_ude3!(node : BaseNode, succ : BaseNode) : BaseNode
    case tail = succ.succ?
    when .nil?
      fold!(node, succ.set!("phải"), MapTag::DrPhrase, dic: 4)
    when .key_is?("住")
      succ.val = ""
      node.as_verb!(nil) if node.is_a?(BaseTerm)
      fold!(node, tail.set!("nổi"), MapTag::Verb, dic: 5)
    when .verb_words?
      node = fold!(node, succ.set!("phải"), MapTag::DrPhrase, dic: 4)
      fold_verbs!(tail, prev: node)
    else
      # TODO: add case here
      fold!(node, succ.set!("phải"), MapTag::DrPhrase, dic: 4)
    end
  end

  def fold_verb_ude3!(node : BaseNode, succ : BaseNode) : BaseNode
    return node unless tail = succ.succ?
    succ.val = ""

    case tail
    # when .pre_bi3?
    # tail = fold_compare_bi3!(tail)
    # fold!(node, tail, MapTag::Vobj, dic: 7)
    when .advb_words?
      tail = fold_adverbs!(tail)

      if tail.adjt_words?
        fold!(node, tail, MapTag::Aform, dic: 5)
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(node, tail, MapTag::Aform, dic: 5)
      elsif tail.verb_words?
        succ.set!("đến")
        fold!(node, tail, tail.tag, dic: 8)
      else
        node
      end
    when .adjt_words?
      fold!(node, tail, MapTag::Aform, dic: 6)
    when .verb_words?
      node = fold!(node, succ, MapTag::Verb, dic: 6)
      fold_verb_compl!(node, tail) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
