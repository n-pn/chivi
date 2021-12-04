module CV::TlRule
  def fold_uzhi!(uzhi : MtNode, prev = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?
    uzhi.val = ""
    tag = succ.key == "都" ? PosTag::Naffil : PosTag::Nform
    succ.val = MTL::UZHI_RIGHTS[succ.key]? || succ.val
    fold!(prev, succ, tag, dic: 2, flip: true)
  end
end
