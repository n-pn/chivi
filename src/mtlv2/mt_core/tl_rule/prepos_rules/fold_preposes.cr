module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    return fold_verbs!(node) if succ.ule?

    case node.tag
    when .pre_ba3? then fold_pre_ba3!(node, succ)
    when .pre_dui? then fold_pre_dui!(node, succ)
    when .pre_bei? then fold_pre_bei!(node, succ)
    when .pre_zai? then fold_pre_zai!(node, succ)
    when .pre_bi3? then fold_compare_bi3!(node, succ)
    else                fold_other_preposes!(node, succ)
    end
  end

  def fold_other_preposes!(node : MtNode, succ : MtNode)
    case node.key
    when "将"
      if succ.maybe_verb?
        succ = fold_adverbs!(succ) if succ.adverbial?
        return fold_verbs!(succ, adverb: node.set!("sẽ"))
      end
    when "与", "和", "同", "跟"
      return fold_compare_prepos(node) || fold_prepos_inner!(node)
    end

    fold_prepos_inner!(node, succ)
  end

  def fold_pre_dui!(node : MtNode, succ = node.succ?) : MtNode
    case succ
    when .nil?, .ends?, .ule?
      node.set!("đúng", PosTag::Adjt)
    when .ude1?
      fold!(node, succ.set!(""), PosTag::Adjt, dic: 2)
    else
      fold_prepos_inner!(node.set!("đối với"), succ)
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos_inner!(node, succ)
    end
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?) : MtNode
    succ = heal_veno!(succ) if succ.veno?

    if succ.verb? || succ.verb_object?
      # TODO: check conditions when prezai can be translated at "đang"
      # node.set!("đang")

      node = fold!(node, succ, succ.tag, dic: 6)
      return fold_verbs!(node)
    end

    fold_prepos_inner!(node, succ)
  end

  def fold_prezai_places?(node : MtNode, noun : MtNode, ude1 : MtNode, tail : MtNode) : MtNode?
    return nil if noun.places?

    unless tail.places?
      return nil unless (local = tail.succ?) && local.locative?
      tail = fold_noun_locality!(noun: tail, locality: local)
      return nil if tail.succ? == local
    end

    fold_ude1!(ude1: ude1, left: noun, right: tail)
  end
end
