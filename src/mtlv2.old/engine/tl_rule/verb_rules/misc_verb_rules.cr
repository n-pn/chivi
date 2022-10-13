module MT::TlRule
  LINKING = {'来', '去', '到', '有', '上', '想', '出'}

  def is_linking_verb?(head : BaseNode, succ : BaseNode?) : Bool
    # puts [head.to_str, succ, "check linking verb"]
    return true if head.vmodals?
    return true if !succ || succ.starts_with?('不')

    head.each do |node|
      next true if (char = node.key[0]?) && LINKING.includes?(char)
    end

    {'了', '过'}.each do |char|
      return {'就', '才', '再'}.includes?(succ.key) if head.ends_with?(char)
    end

    false
  end

  def find_verb_after(right : BaseNode)
    while right = right.succ?
      # puts ["find_verb", right]

      case right
      when .plsgn?, .mnsgn?, .verbal?, .preposes?
        return right
      when .adverbial?, .comma?
        next
      else
        return nil
      end
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def find_verb_after_for_prepos(node : BaseNode, skip_comma = true) : BaseNode?
    while node = node.succ?
      case node
      when .plsgn?, .mnsgn? then return node
      when .comma?          then return nil if skip_comma
      when .v_shang?, .v_xia?
        return node if node.succ?(&.ule?)
      when .vmodals?, .verbal? then return node
      when .adjective?
        return nil unless {"相同", "类似"}.includes?(node.key)
        return node.set!(PosTag::Vintr)
      else
        if node.key == "一" && (succ = node.succ?) && succ.verb?
          return fold!(node.set!("một phát"), succ, succ.tag, dic: 5, flip: true)
        end

        return nil unless node.adverbial? || node.pdash?
      end
    end
  end

  def scan_verb!(node : BaseNode)
    case node
    when .adverbial? then fold_adverbs!(node)
    when .preposes?  then fold_preposes!(node)
    else                  fold_verbs!(node)
    end
  end

  def need_2_objects?(node : BaseNode)
    node.each do |x|
      if body = x.body?
        next true if need_2_objects?(body)
      else
        next true if x.v2_object?
      end
    end

    false
  end

  def fold_left_verb!(node : BaseNode, prev : BaseNode?)
    return node unless prev && prev.adverbial?
    fold_adverb_node!(prev, node)
  end
end
