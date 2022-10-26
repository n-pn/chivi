module MT::Core
  def fix_uniqword!(node : MonoNode)
    case node
    when .hao_word?    then fix_wd_hao!(node)
    when .quanti_or_x? then fix_qttemp!(node)
    when .maybe_auxi?  then fix_vauxil!(node)
    when .maybe_cmpl?  then fix_vcompl!(node)
    else
      node
    end
  end

  def self.fix_wd_hao!(whao : MonoNode)
    case whao.succ
    when .common_nouns?
      whao.val = "tốt"
      whao.tag, whao.pos = PosTag.make(:amod)
    when .common_verbs?, .adjt_words?, .preposes?
      whao.val = "thật"
      whao.tag = MtlTag::AdvHao
    else
      if whao.real_prev.try(&.verb_take_res_cmpl?)
        whao.val = "tốt"
        whao.pos = MtlPos::MaybeCmpl
      else
        whao.val = "tốt"
        whao.tag = MtlTag::Adjt
        whao.pos = MtlPos::CanBePred
      end
    end

    whao
  end
end
