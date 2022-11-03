module MT::Rules
  def fix_uniqword!(node : MonoNode, succ = node.succ)
    case node
    when .hao_word?   then fix_hao_word!(node, succ)
    when .maybe_auxi? then fix_vauxil!(node)
    else
      node
    end
  end

  def self.fix_hao_word!(whao : MonoNode, succ = whao.succ)
    case succ
    when .common_nouns?
      whao.val = "tốt"
      whao.tag, whao.pos = PosTag.make(:amod)
    when .common_verbs?, .adjt_words?, .preposes?
      whao.val = "thật"
      whao.tag = MtlTag::AdvHao
    else
      whao.val = "tốt"
      whao.tag = MtlTag::Adjt
      whao.pos = MtlPos::CanBePred
    end

    whao
  end
end
