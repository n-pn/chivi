module CV::TlRule
  def fold_uzhi!(uzhi : MtNode, prev = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?

    if val = MTL::UZHI_RIGHTS[succ.key]?
      succ.val = val
    elsif succ.adjt?
      return prev
    end

    uzhi.val = ""
    tag = succ.key == "都" ? PosTag::Naffil : PosTag::Nform

    fold!(prev, succ, tag, dic: 2, flip: true)
  end
end
