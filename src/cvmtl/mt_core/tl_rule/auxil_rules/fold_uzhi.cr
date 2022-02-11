module CV::TlRule
  def fold_uzhi!(uzhi : MtNode, prev : MtNode = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?

    unless tag = MtDict.fix_uzhi(succ)
      return prev if succ.adjt?
      tag = PosTag::Nform
    end

    uzhi.val = ""

    if prev.numbers? && succ.numbers?
      # TODO: handle this in fold_number!
      if node = prev.dig_key?("分")
        node.val = node.val.sub(/\s*phầ|ân\*/, "")
        uzhi.val = "phần"
      end

      tag = PosTag::Number
    end

    fold!(prev, succ, tag, dic: 2, flip: true)
  end
end
