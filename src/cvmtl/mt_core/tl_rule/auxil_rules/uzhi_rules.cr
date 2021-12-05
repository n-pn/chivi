module CV::TlRule
  def fold_uzhi!(uzhi : MtNode, prev : MtNode = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?

    if val = MTL::UZHI_RIGHTS[succ.key]?
      succ.val = val
    elsif succ.adjt?
      return prev
    end

    uzhi.val = ""

    case
    when succ.key == "都"
      tag = PosTag::Naffil
    when prev.numbers? && succ.numbers?
      # TODO: handle this in fold_number!
      if node = prev.has_key?("分")
        node.val = node.val.sub(/\s*phầ|ân\*/, "")
        uzhi.val = "phần"
      end

      tag = PosTag::Number
    else
      tag = PosTag::Nform
    end

    fold!(prev, succ, tag, dic: 2, flip: true)
  end
end
