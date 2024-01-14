module M1::TlRule
  def is_linking_verb?(head : MtNode, succ : MtNode?) : Bool
    # puts [node, succ, "check linking verb"]
    return true if head.vmodals?
    return true if !succ || succ.starts_with?('不')

    head.each do |node|
      next unless node.is_a?(MtDefn)
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
  def find_verb_after_for_prepos(node : MtNode, skip_comma = true) : MtNode?
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

  def scan_verb!(node : MtNode)
    case node
    when .adverbial? then fold_adverbs!(node)
    when .preposes?  then fold_preposes!(node)
    else                  fold_verbs!(node)
    end
  end

  def need_2_objects?(node : MtList)
    node.list.any? { |x| need_2_objects?(x) }
  end

  def need_2_objects?(node : MtDefn)
    need_2_objects?(node.key)
  end

  def need_2_objects?(key : String)
    SpDict.v_ditran.has?(key)
  end

  def fold_left_verb!(node : MtNode, prev : MtNode?)
    return node unless prev && prev.adverbial?
    fold_adverb_node!(prev, node)
  end
end
