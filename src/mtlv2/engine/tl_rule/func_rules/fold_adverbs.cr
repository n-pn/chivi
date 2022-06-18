module MtlV2::TlRule
  def fold_adverbs!(node : BaseNode, succ = node.succ?) : BaseNode
    if !succ || succ.ends?
      node.val = "vậy" if node.key == "也"
      return node
    end

    # puts [node, succ]

    case node.tag
    when .adv_bu4? then fold_adv_bu!(node, succ)
    when .adv_mei? then fold_adv_mei!(node, succ)
    when .adv_fei? then fold_adv_fei!(node, succ)
    else                fold_adverb_base!(node, succ)
    end
  end

  def fold_adv_bu!(node : BaseNode, succ = node.succ) : BaseNode
    case succ.tag
    when .vmodals?
      fold_vmodals!(succ, nega: node)
    when .pre_dui?
      succ = fold_pre_dui!(succ)
      fold!(node, succ, succ.tag, dic: 9)
    when .adverbial?
      node = fold!(node, succ, succ.tag, dic: 4)
      return node unless succ = node.succ?
      fold_adverb_base!(node, succ)
    when .verbal?
      succ = MtDict.fix_verb!(succ) if succ.veno?
      node = fold!(node, succ, succ.tag, dic: 4)
      fold_verbs!(node)
    when .adjective?
      succ = MtDict.fix_adjt!(succ) if succ.ajno?
      fold_adjts!(succ, adverb: node)
    else
      return node unless succ.key == "一样"
      succ.set!("giống nhau", PosTag::Vintr)
      fold_verbs!(succ, adverb: node)
    end
  end

  def fold_adv_mei!(node : BaseNode, succ = node.succ) : BaseNode
    case succ.tag
    when .verbal?
      succ = heal_veno!(succ) if succ.veno?
      # TODO: add more cases
      node.val = succ.succ?(&.uzhe?) ? "không" : node.prev?(&.subject?) ? "chưa" : "không có"
      fold_verbs!(succ, adverb: node)
    when .adjt?, .ajad?, .ajno?
      fold!(node.set!("không"), succ, PosTag::Adjt, dic: 2)
    else
      node
    end
  end

  def fold_adv_fei!(node : BaseNode, succ = node.succ) : BaseNode
    case succ
    when .modi?, .noun?, .ajno?, .veno?
      node = fold!(node, succ, PosTag::Modi, dic: 7)
      fold_adjts!(node)
    when .verbal?
      node = fold!(node, succ, succ.tag, dic: 6)
      fold_verbs!(node)
    else
      node.set!("không phải là")
    end

    # TODO: check for key when 没 mean "không"
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adverb_base!(node : BaseNode, succ = node.succ) : BaseNode
    node, succ = fix_adverb!(node, succ)
    return node unless succ

    case succ.tag
    when .v_shi?
      node = fold!(node, succ, succ.tag, dic: 3)
      fold_v_shi!(node)
    when .v_you?
      return node unless (noun = succ.succ?) && noun.noun?
      succ = fold!(succ, noun, PosTag::Aform, dic: 5)
      fold_adverb_node!(node, succ)
    when .vmodals?
      fold_vmodals!(succ, nega: node)
    when .veno?
      fold_adverb_verb!(node, MtDict.fix_verb!(succ))
    when .v_compare?
      if comp = fold_compare(succ)
        fold_adverb_node!(node, comp)
      else
        fold_adverb_verb!(node, succ)
      end
    when .uguo?, .verbal?
      fold_adverb_verb!(node, succ)
    when .ajno?
      fold_adjts!(MtDict.fix_adjt!(succ), adverb: node)
    when .adjective?
      succ.tag = PosTag::Adjt if succ.ajno?
      fold_adjts!(succ, adverb: node)
    when .adv_bu4?
      succ.succ? { |tail| succ = fold_adv_bu!(succ, tail) }
      fold!(node, succ, succ.tag, dic: 2)
    when .adverb?
      succ = fold_adverbs!(succ)
      node = fold!(node, succ, succ.tag, dic: 6)
    when .locative?
      return node unless node.key = "最"
      fold!(node, succ, succ.tag, dic: 7, flip: true)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    when .ude3?
      fold_adverb_ude3!(node, succ)
    else
      case node
      when .vead?
        fold_verbs!(MtDict.fix_verb!(node))
      when .ajad?
        fold_adjts!(MtDict.fix_adjt!(node))
      else
        node
      end
    end
  end

  def fix_adverb!(node : BaseNode, succ = node.succ) : {BaseNode, BaseNode?}
    case succ
    when succ.vead? || succ.ajad? || succ.adj_hao?
      if is_adverb?(succ)
        succ = heal_adj_hao!(succ) if succ.adj_hao?
        node = fold!(node, succ, PosTag::Adverb, dic: 5)
        succ = node.succ?
      elsif succ.vead?
        succ = MtDict.fix_verb!(succ)
      elsif succ.adj_hao?
        # TODO: inspect more on this case
        succ = heal_adj_hao!(succ)
      else
        succ = MtDict.fix_adjt!(succ)
      end
    when succ.concoord?
      return {node, nil} unless succ.key == "和"
      succ.set!(PosTag::Prepos)
    end

    {node, succ}
  end

  def heal_adj_hao!(node : BaseNode)
    case node.succ?
    when .nil?       then node
    when .adjective? then node.set!("thật")
    when .verbal?    then node.set!("dễ")
    else                  node.set!("tốt")
    end
  end

  def fold_adverb_verb!(adverb : BaseNode, verb : BaseNode)
    case adverb.key
    when "老" then adverb.val = "luôn"
    when "光" then adverb.val = "chỉ riêng"
    when "白" then adverb.val = "phí công"
    when "正" then adverb.val = "đang" unless verb.v_shi?
    end

    fold_verbs!(verb, adverb: adverb)
  end

  def is_adverb?(node : BaseNode) : Bool
    while node = node.succ?
      case node
      when .comma?
        return false unless node = node.succ?
      when .plsgn?, .mnsgn?, .verbal?, .preposes?, .adjective?, .adverbial?, .vmodals?
        return true
      when .concoord?
        return false unless node.key == "和"
        node.set!(PosTag::Prepos)
        # TODO: deep checking
        return true
      when .ude3?
        return node.succ?(&.verbal?) || false
      else
        return false
      end
    end

    false
  end
end