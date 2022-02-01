module CV::TlRule
  def is_linking_verb?(head : MtNode, succ : MtNode?) : Bool
    # puts [node, succ, "check linking verb"]
    return true if head.vmodals?
    return true if !succ || succ.starts_with?('不')

    head.each do |node|
      next unless char = node.key[0]?
      return true if {'来', '去', '到', '有', '上', '想', '出'}.includes?(char)
    end

    {'了', '过'}.each do |char|
      return {'就', '才', '再'}.includes?(succ.key) if head.ends_with?(char)
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
      # when .plsgn?, .mnsgn? then return node
      when .comma? then return nil if skip_comma
      when .v_shang?, .v_xia?
        return node if node.succ?(&.ule?)
      when .vmodals?, .verbs? then return node
      when .adjts?
        return nil unless {"相同", "类似"}.includes?(node.key)
        return node.set!(PosTag::Vintr)
      else
        if node.key == "一" && (succ = node.succ?) && succ.verb?
          return fold!(node.set!("một phát"), succ, succ.tag, dic: 5, flip: true)
        end

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

  def need_2_objects?(node : MtNode)
    node.each { |x| return true if need_2_objects?(node.key) }
    false
  end

  def need_2_objects?(key : String)
    MtDict::VERBS_2_OBJECTS.has_key?(key)
  end

  def fold_left_verb!(node : MtNode, prev : MtNode?)
    return node unless prev && prev.adverbs?
    fold_adverb_node!(prev, node)
  end
end
