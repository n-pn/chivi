module CV::TlRule
  def fold_preposes!(node : BaseNode, succ = node.succ?, mode = 0) : BaseNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_ba3? then fold_pre_ba3!(node, succ, mode: mode)
    when .pre_dui? then fold_pre_dui!(node, succ, mode: mode)
    when .pre_bei? then fold_pre_bei!(node, succ, mode: mode)
    when .pre_zai? then fold_pre_zai!(node, succ, mode: mode)
      # when .pre_bi3? then fold_compare_bi3!(node, succ, mode: mode)
    else fold_other_preposes!(node, succ, mode)
    end
  end

  def fold_other_preposes!(node : BaseNode, succ : BaseNode, mode : Int32)
    case node.tag
    when .pre_jiang?
      fold = fold_prepos_inner!(node, succ, mode: mode)
      return fold unless (fold.succ? == succ) && succ.verbal?
      return fold_verbs!(succ, prev: node.set!("sẽ"))
    when .pre_he2?, .pre_yu3?
      return fold_compare(node, succ) || fold_prepos_inner!(node)
    when .pre_tong?, .pre_gen1?
      if fold = fold_compare(node, succ)
        node.val = fold.dic == 0 ? "giống" : ""
        return fold
      end
    end

    fold_prepos_inner!(node, succ, mode: mode)
  end

  def fold_pre_dui!(node : BaseNode, succ = node.succ?, mode = 0) : BaseNode
    return node.set!("đúng", PosTag::Adjt) if !succ || succ.boundary?

    # TODO: combine grammar

    case succ.tag
    when .pt_dep?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Adjt, dic: 7)
    when .pt_le?
      # succ.val = "" unless keep_pt_le?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Adjt, dic: 7)
    when .boundary?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    else
      fold_prepos_inner!(node.set!("đối với"), succ, mode: mode)
    end
  end

  def fold_pre_bei!(node : BaseNode, succ = node.succ?, mode = 0) : BaseNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos_inner!(node, succ, mode: mode)
    end
  end

  def fold_pre_zai!(node : BaseNode, succ = node.succ?, mode = 0) : BaseNode
    succ = heal_mixed!(succ) if succ.polysemy?

    if succ.verb? || succ.vobj?
      # TODO: check conditions when prezai can be translated at "đang"
      # node.set!("đang")

      node = fold!(node, succ, succ.tag, dic: 6)
      return fold_verbs!(node)
    end

    fold_prepos_inner!(node, succ, mode: mode)
  end

  def fold_prezai_locale?(node : BaseNode, noun : BaseNode, ude1 : BaseNode, tail : BaseNode) : BaseNode?
    return nil if noun.locale?

    unless tail.locale?
      return nil unless tail = fold_noun_space!(noun: tail)
    end

    fold_ude1_left!(ude1: ude1, left: noun, right: tail)
  end
end
