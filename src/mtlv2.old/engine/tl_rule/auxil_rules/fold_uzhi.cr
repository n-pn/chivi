module MtlV2::TlRule
  def fold_uzhi!(uzhi : BaseNode, prev : BaseNode = uzhi.prev, succ = uzhi.succ?) : BaseNode
    return prev if !succ || succ.ends?
    uzhi.val = ""

    if succ.nhanzi? && is_percent?(prev, uzhi)
      # TODO: handle this in fold_number!
      tag = PosTag::Number
    elsif !(tag = MtDict.fix_uzhi(succ))
      return prev if succ.adjt?
      tag = PosTag::NounPhrase
    end

    fold!(prev, succ, tag, dic: 3, flip: true)
  end

  def is_percent?(prev : BaseNode, uzhi : BaseNode)
    if body = prev.body?
      return false unless body.nhanzi?
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
