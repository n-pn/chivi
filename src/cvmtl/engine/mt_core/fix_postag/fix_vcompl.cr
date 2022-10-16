module MT::Core
  def fix_vcompl!(node : MonoNode) : MonoNode
    case node
    when .vdir? then fix_dir_cmpl!(node)
    else             fix_res_cmpl!(node)
    end
  end

  def self.fix_res_cmpl!(cmpl : MonoNode) : MonoNode
    if cmpl.real_prev.try(&.verb_take_res_cmpl?)
      cmpl.swap_val!
    else
      cmpl.tag, cmpl.pos = PosTag.not_vcompl(cmpl.key)
    end

    cmpl
  end

  def self.fix_dir_cmpl!(cmpl : MonoNode) : MonoNode
    case cmpl.tag
    when .adjt_words?, .common_verbs?
      cmpl.swap_val!
    else
      cmpl.tag, cmpl.pos = PosTag::Verb
    end

    cmpl
  end
end
