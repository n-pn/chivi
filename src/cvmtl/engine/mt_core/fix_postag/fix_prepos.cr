module MT::Core
  def fix_ba3!(node : MonoNode, prev = node.prev)
    case prev
    when .verb_take_verb?
      is_prepos = word_is_prepos?(node.succ)
    when .number_words?, .common_verbs?, .pro_split?
      is_prepos = false
    when .quanti_words?, .noun_words?, .pro_pers?
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
    when .noun_words? then "chiếc"
    end
  end

  def fix_he3yu2!(node : MonoNode, succ = node.succ) : MonoNode
    # FIXME: add more cases here
    if word_is_prepos?(succ)
      node.tag = node.wd_he2? ? MtlTag::PreHe2 : MtlTag::PreYu3
    else
      node.val = "và" if node.tag.wd_he2?
      node.tag = MtlTag::Concoord
      node.pos = MtlPos::BondWord
    end

    node
  end

  private def word_is_prepos?(noun : MtNode)
    return false unless noun.tag.noun_words? && (tail = noun.succ?)
    tail.preposes? || tail.pt_cmps? || tail.common_verbs?
  end

  def fix_pt_dev!(node : MonoNode)
    Log.info { "TODO fix pt_dev!".colorize.yellow }
    node
  end

  def fix_pt_der!(node : MonoNode)
    Log.info { "TODO fix pd_der!".colorize.yellow }
    node
  end
end
