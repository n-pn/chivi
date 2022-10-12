module MT::Core
  def fix_he3yu2!(node : BaseTerm, succ = node.succ) : BaseTerm
    # FIXME: add more cases here
    if he3yu2_is_prepos?(succ)
      node.tag = node.wd_he2? ? MtlTag::PreHe2 : MtlTag::PreYu3
    else
      node.val = "và" if node.tag.wd_he2?
      node.tag = MtlTag::Concoord
      node.pos = MtlPos::BondWord
    end

    node
  end

  private def he3yu2_is_prepos?(noun : BaseNode)
    return false unless noun.tag.noun_words? && (tail = noun.succ?)
    tail.verb_words? || tail.preposes? || tail.pt_cmps?
  end

  def fix_pt_dev!(node : BaseTerm)
    Log.info { "TODO fix pt_dev!".colorize.yellow }
    node
  end

  def fix_pt_der!(node : BaseTerm)
    Log.info { "TODO fix pd_der!".colorize.yellow }
    node
  end
end
