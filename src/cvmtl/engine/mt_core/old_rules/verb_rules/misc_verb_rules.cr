module MT::TlRule
  # def is_linking_verb?(head : BaseNode, succ : BaseNode?) : Bool
  #   # puts [node, succ, "check linking verb"]
  #   return true if head.modal_verbs?
  #   return true if !succ || succ.starts_with?('不')

  #   head.each do |node|
  #     next unless node.is_a?(MonoNode)
  #     next unless char = node.key[0]?
  #     return true if {'来', '去', '到', '有', '上', '想', '出'}.includes?(char)
  #   end

  #   {'了', '过'}.each do |char|
  #     return {'就', '才', '再'}.includes?(succ.key) if head.ends_with?(char)
  #   end

  #   false
  # end

  def find_verb_after(right : BaseNode)
    while right = right.succ?
      # puts ["find_verb", right]

      case right
      when .pl_mark?, .mn_mark?, .verb_words?, .preposes?
        return right
      when .advb_words?, .comma?
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
      when .pl_mark?, .mn_mark? then return node
      when .comma?              then return nil if skip_comma
      when .v_shang?, .v_xia?
        return node if node.succ?(&.pt_le?)
      when .modal_verbs?, .verb_words? then return node
      when .adjt_words?
        return nil unless {"相同", "类似"}.includes?(node.key)
        return node.set!(MapTag::Vint)
      else
        if node.key == "一" && (succ = node.succ?) && succ.verb?
          return fold!(node.set!("một phát"), succ, succ.tag, flip: true)
        end

        return nil unless node.advb_words?
      end
    end
  end

  def fold_left_verb!(node : BaseNode, prev : BaseNode?)
    return node unless prev && prev.advb_words?
    fold_adverb_node!(prev, node)
  end
end
