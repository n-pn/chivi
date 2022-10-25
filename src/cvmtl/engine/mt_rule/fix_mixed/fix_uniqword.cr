module MT::Core
  def fix_uniqword!(node : MonoNode)
    case node
    when .wd_hao?  then fix_wd_hao!(node)
    when .qt_temp? then fix_qttemp!(node)
    when .vauxil?  then fix_vauxil!(node)
    when .vcompl?  then fix_vcompl!(node)
    else
      node
    end
  end

  def self.fix_wd_hao!(whao : MonoNode)
    case whao.succ
    when .common_nouns?
      whao.val = "tốt"
      whao.tag, whao.pos = PosTag::Amod
    when .common_verbs?, .adjt_words?, .preposes?
      whao.val = "thật"
      whao.tag = MtlTag::AdvHao
    else
      if whao.real_prev.try(&.verb_take_res_cmpl?)
        whao.val = "tốt"
        whao.pos = MtlPos::Vcompl
      else
        whao.val = "tốt"
        whao.tag = MtlTag::Adjt
        whao.pos = MtlPos::None
      end
    end

    whao
  end
end
