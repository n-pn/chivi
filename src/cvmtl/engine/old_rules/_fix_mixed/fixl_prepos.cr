module MT::Rules
  def fix_dui!(node : MonoNode, prev = node.prev)
    case prev
    when .advb_words?
      node.val = "đúng"
      node.tag = MtlTag::Adjt
    when .verb_take_res_cmpl?
      node.val = "đúng"
      node.pos = MtlPos::Vcompl
    when .numbers?
      node.val = "đôi"
      node.tag = MttTag::Qtnoun
    else
      case node.succ
      when .ptcl_dep?, .ptcl_le?
        node.val = "đúng"
        node.tag = MtlTag::Adjt
      when .aspect?, .numbers?
        node.val = "đối"
        node.tag = MtlTag::Verb
      else
        node.val = "đối với"
        node.alt = "với"
        node.tag = MtlTag::PreDui
        node.pos = MtlPos::AtTail
      end
    end

    node
  end

  def fix_ba3!(node : MonoNode, prev = node.prev)
    case prev
    when .verb_take_verb?
      is_prepos = word_is_prepos?(node.succ)
    when .number_words?, .common_verbs?, .mod_prons?
      is_prepos = false
    when .quanti_words?, .all_nouns?, .per_prons?
      is_prepos = true
    else
      is_prepos = word_is_prepos?(node.succ)
    end

    if is_prepos
      node.tag = MtlTag::PreBa3
      node.val = "đem"
    elsif val = return_val_if_ba3_is_qtnoun(node.succ)
      node.tag = MtlTag::Qtnoun
      node.val = val
    else
      node.tag = MtlTag::Qtverb
      node.val = "phát"
    end

    node
  end

  private def return_val_if_ba3_is_qtnoun(noun : MtNode)
    case noun
    when .weapon_obj? then "thanh"
    when .inhand_obj? then "nắm"
    when .all_nouns?  then "chiếc"
    end
  end

  def fix_he3yu2!(node : MonoNode, succ = node.succ) : MonoNode
    # FIXME: add more cases here
    if word_is_prepos?(succ)
      node.tag = node.he2_word? ? MtlTag::PrepHe2 : MtlTag::PrepYu3
    else
      node.val = "và" if node.tag.he2_word?
      node.tag = MtlTag::Concoord
      node.pos = MtlPos::JoinWord
    end

    node
  end

  private def word_is_prepos?(noun : MtNode)
    return false unless noun.tag.all_nouns? && (tail = noun.succ?)
    tail.preposes? || tail.ptcl_cmps? || tail.common_verbs?
  end
end
