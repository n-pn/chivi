module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_ba3? then fold_pre_ba3!(node, succ, mode: mode)
    when .pre_dui? then fold_pre_dui!(node, succ, mode: mode)
    when .pre_bei? then fold_pre_bei!(node, succ, mode: mode)
    when .pre_zai? then fold_pre_zai!(node, succ, mode: mode)
    when .pre_bi3? then fold_compare_bi3!(node, succ, mode: mode)
    else                fold_other_preposes!(node, succ, mode)
    end
  end

  def fold_other_preposes!(node : MtNode, succ : MtNode, mode : Int32)
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

  def fold_pre_dui!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node.set!("đúng", PosTag::Unkn) if !succ || succ.boundary?

    # TODO: combine grammar

    case succ.tag
    when .pd_dep?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Unkn, dic: 7)
    when .pt_le?
      # succ.val = "" unless keep_pt_le?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Unkn, dic: 7)
    when .boundary?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    else
      fold_prepos_inner!(node.set!("đối với"), succ, mode: mode)
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos_inner!(node, succ, mode: mode)
    end
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    succ = heal_mixed!(succ) if succ.polysemy?

    if succ.verb? || succ.verb_object?
      # TODO: check conditions when prezai can be translated at "đang"
      # node.set!("đang")

      node = fold!(node, succ, succ.tag, dic: 6)
      return fold_verbs!(node)
    end

    fold_prepos_inner!(node, succ, mode: mode)
  end

  def fold_prezai_places?(node : MtNode, noun : MtNode, ude1 : MtNode, tail : MtNode) : MtNode?
    return nil if noun.places?

    unless tail.places?
      return nil unless tail = fold_noun_space!(noun: tail)
    end

    fold_noun_ude1!(noun, ude1, tail)
  end
end
