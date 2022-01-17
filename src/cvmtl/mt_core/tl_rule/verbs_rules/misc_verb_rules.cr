module CV::TlRule
  def is_linking_verb?(node : MtNode, succ : MtNode?) : Bool
    return true if node.vmodals?

    # puts [node, succ, "check linking verb"]

    {'来', '去', '到', '有', '上', '着', '想', '出'}.each do |char|
      return true if node.ends_with?(char)
    end

    return true if !succ || succ.starts_with?('不')

    {'了', '过'}.each do |char|
      return {'就', '才', '再'}.includes?(succ.key) if node.ends_with?(char)
    end

    false
  end

  def find_verb_after(right : MtNode)
    while right = right.succ?
      # puts ["find_verb", right]
      return right if right.verbs? || right.preposes?
      return nil unless right.adverbs? || right.comma? # || right.conjunct?
    end
  end

  def find_verb_after_for_prepos(node : MtNode, skip_comma = true) : MtNode?
    while node = node.succ?
      case node
      when .vmodals?, .verbs?
        return node unless node.v_shang? || node.v_xia?
        return node if node.succ?(&.ule?)
        # when .plsgn?, .mnsgn? then return node
      when .comma? then return nil if skip_comma
      else
        return nil unless node.adverbs? || node.pdash?
      end
    end
  end

  def scan_verb!(node : MtNode)
    case node
    when .adverbs?  then fold_adverbs!(node)
    when .preposes? then fold_preposes!(node)
    else                 fold_verbs!(node)
    end
  end

  def need_2_objects?(key : String)
    MtDict::VERBS_2_OBJECTS.has_key?(key)
  end

  def should_apply_ude1_after_verb?(verb : MtNode)
    # TODO: add more cases here
    return false unless prev = verb.prev?

    case prev.tag
    when .comma? then true
    when .nouns?
      return true unless head = prev.prev?
      head.v_shi? || head.none? || head.puncts?
    else false
    end
  end

  def fold_left_verb!(node : MtNode, prev : MtNode?)
    return node unless prev && prev.adverbs?
    fold_adverb_node!(prev, node)
  end

  def fold_verb_uzhe!(prev : MtNode, uzhe : MtNode, succ = uzhe.succ?) : MtNode
    uzhe.val = ""

    if succ && succ.verbs?
      # succ = fold_verbs!(succ)
      fold!(prev, succ, PosTag::Verb, dic: 5)
    else
      fold!(prev, uzhe, PosTag::Verb, dic: 6)
    end
  end
end
