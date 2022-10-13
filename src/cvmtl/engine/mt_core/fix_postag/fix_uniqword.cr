module MT::Core
  def fix_uniqword!(node : BaseTerm)
    case node
    when .qttemp? then fix_qttemp!(node)
    when .vauxil? then fix_vauxil!(node)
    when .vcompl? then fix_vcompl!(node)
    else
      node
    end
  end

  def self.fix_hao_word!(haow : BaseTerm)
    case haow.succ
    when .common_nouns?
      haow.set!("tốt", MapTag.make(:adj_hao, :adjtish))
    when .common_verbs?, .adjt_words?, .preposes?
      haow.set!("thật", MapTag.make(:adv_hao, :advbial))
    else
      if haow.real_prev.try(&.verb_take_res_cmpl?)
        haow.set!("tốt", MapTag.make(:cmpl_hao, :vcompl))
      else
        haow
      end
    end
  end

  def self.fix_res_cmpl!(cmpl : BaseTerm)
    if cmpl.real_prev.try(&.verb_take_res_cmpl?)
      cmpl.swap_val!
    else
      cmpl.set!(PosTag.not_vcompl(cmpl.key))
    end
  end

  def self.fix_dir_cmpl!(cmpl : BaseTerm)
    case cmpl.tag
    when .adjt_words?, .common_verbs?
      cmpl.swap_val!
    else
      cmpl.set!(MapTag::Verb)
    end
  end
end
