module MT::TlRule
  def fold_uzhi!(uzhi : MtNode, prev : MtNode = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?
    uzhi.val = ""

    if succ.nhanzis? && is_percent?(prev, uzhi)
      # TODO: handle this in fold_number!
      tag = PosTag::Number
    elsif !(tag = MtDict.fix_uzhi(succ))
      return prev if succ.adjt?
      tag = PosTag::NounPhrase
    end

    fold!(prev, succ, tag, dic: 3, flip: true)
  end

  def is_percent?(prev : MtNode, uzhi : MtNode)
    if body = prev.body?
      return false unless body.nhanzis?
      return false unless succ = body.succ?

      case succ.key
      when "分"
        succ.val = ""
        uzhi.val = "phần"
        true
      else
        false
      end
    else
      prev.key =~ /^[零〇一二三四五六七八九十百千万亿]+分$/
    end
  end
end
