module MT::Core
  def fix_uniqword!(node : MonoNode)
    case node
    when .qttemp? then fix_qttemp!(node)
    when .vauxil? then fix_vauxil!(node)
    when .vcompl? then fix_vcompl!(node)
    else
      node
    end
  end

  def self.fix_hao_word!(haow : MonoNode)
    case haow.succ
    when .common_nouns?
      haow.set!("tốt", PosTag.make(:adj_hao, :adjtish))
    when .common_verbs?, .adjt_words?, .preposes?
      haow.set!("thật", PosTag.make(:adv_hao, :advbial))
    else
      if haow.real_prev.try(&.verb_take_res_cmpl?)
        haow.set!("tốt", PosTag.make(:cmpl_hao, :vcompl))
      else
        haow
      end
    end
  end

  def self.fix_res_cmpl!(cmpl : MonoNode)
    if cmpl.real_prev.try(&.verb_take_res_cmpl?)
      cmpl.swap_val!
    else
      cmpl.set!(PosTag.not_vcompl(cmpl.key))
    end
  end

  def self.fix_dir_cmpl!(cmpl : MonoNode)
    case cmpl.tag
    when .adjt_words?, .common_verbs?
      cmpl.swap_val!
    else
      cmpl.set!(PosTag::Verb)
    end
  end
end
