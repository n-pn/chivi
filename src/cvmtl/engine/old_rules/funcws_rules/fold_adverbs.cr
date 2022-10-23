module MT::TlRule
  def fold_adverbs!(node : MtNode, succ = node.succ?) : MtNode
    if !succ || succ.boundary?
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

  def fold_adv_bu!(node : MtNode, succ = node.succ) : MtNode
    succ = heal_mixed!(succ) if succ.polysemy?

    case succ.tag
    when .modal_verbs?
      fold_vmodal!(succ, nega: node)
    when .pre_dui?
      succ = fold_pre_dui!(succ)
      fold!(node, succ, succ.tag)
    when .advb_words?
      node = fold!(node, succ, succ.tag)
      return node unless succ = node.succ?
      fold_adverb_base!(node, succ)
    when .verb_words?
      node = fold!(node, succ, succ.tag)
      fold_verbs!(node)
    when .adjt_words?
      node = fold!(node, succ, succ.tag)
      fold_adjts!(node)
    else
      return node unless succ.key == "一样"
      succ.set!("giống nhau", PosTag::Adjt)
      fold_verbs!(succ, node)
    end
  end

  def fold_adv_mei!(node : MtNode, succ = node.succ) : MtNode
    succ = heal_mixed!(succ) if succ.polysemy?

    case succ.tag
    when .verb_words?
      node.val = succ.succ?(&.pt_zhe?) ? "không" : node.prev?(&.nounish?) ? "chưa" : "không có"
      fold_verbs!(succ, prev: node)
    when .adjt?, .pl_ajad?, .pl_ajno?
      fold!(node.set!("không"), succ, PosTag::Adjt)
    else
      node
    end
  end

  def fold_adv_fei!(node : MtNode, succ = node.succ) : MtNode
    case succ
    when .amod_words?, .common_nouns?, .pl_ajno?, .pl_veno?
      node = fold!(node, succ, PosTag::Amod)
      fold_adjts!(node)
    when .verb_words?
      node = fold!(node, succ, succ.tag)
      fold_verbs!(node)
    else
      node.set!("không phải là")
    end

    # TODO: check for key when 没 mean "không"
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adverb_base!(node : MtNode, succ = node.succ) : MtNode
    case succ.tag
    when .v_you?
      return node unless (noun = succ.succ?) && noun.common_nouns?
      succ = fold!(succ, noun, PosTag::Aform)
      fold_adverb_node!(node, succ)
    when .modal_verbs?
      fold_vmodal!(succ, nega: node)
    when .verb_words?
      fold_adverb_verb!(node, succ)
    when .adjt_words?
      succ.tag = PosTag::Adjt if succ.pl_ajno?
      fold_adjts!(succ, prev: node)
    when .adv_bu4?
      succ.succ? { |tail| succ = fold_adv_bu!(succ, tail) }
      fold!(node, succ, succ.tag)
    when .advb_words?
      succ = fold_adverbs!(succ)
      node = fold!(node, succ, succ.tag)
    when .locat?
      return node unless node.key = "最"
      fold!(node, succ, succ.tag, flip: true)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag)
    when .pt_der?
      fold_adverb_ude3!(node, succ)
    else
      node
    end
  end

  # def fix_adverb!(node : MtNode, succ = node.succ) : {MtNode, MtNode?}
  #   case succ
  #   when .v_shi?
  #     node = fold!(node, succ, PosTag::Vead)
  #     succ = node.succ?
  #   when .wd_hao?
  #     succ = heal_wd_hao!(succ)
  #   when .concoord?
  #     return {node, nil} unless succ.key == "和"
  #     succ.set!(PosTag::Prepos)
  #   end

  #   {node, succ}
  # end

  def heal_wd_hao!(node : MtNode)
    case node.succ?
    when .nil? then node
    when .adjt_words?, .verb_words?
      node.set!("thật", PosTag::Adverb)
    else
      node.set!("tốt")
    end
  end

  def fold_adverb_verb!(adverb : MtNode, verb : MtNode)
    case adverb.key
    when "老" then adverb.val = "luôn"
    when "光" then adverb.val = "chỉ riêng"
    when "白" then adverb.val = "phí công"
    when "正" then adverb.val = "đang" unless verb.v_shi?
    end

    fold_verbs!(verb, prev: adverb)
  end

  def is_adverb?(node : MtNode) : Bool
    while node = node.succ?
      case node
      when .comma?
        return false unless node = node.succ?
      when .pl_mark?, .mn_mark?, .verb_words?, .preposes?, .adjt_words?, .advb_words?, .modal_verbs?
        return true
      when .concoord?
        return false unless node.key == "和"
        node.set!(PosTag::Prepos)
        # TODO: deep checking
        return true
      when .pt_der?
        return node.succ?(&.verb_words?) || false
      else
        return false
      end
    end

    false
  end
end
