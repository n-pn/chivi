module MT::TlRule
  def fold_uzhi!(uzhi : BaseNode, prev : BaseNode = uzhi.prev, succ = uzhi.succ?) : BaseNode
    return prev if !succ || succ.boundary?
    uzhi.val = ""

    if succ.nhanzis? && is_percent?(prev, uzhi)
      # TODO: handle this in fold_number!
      tag = MapTag::Numeric
    end

    tag ||= MapTag::Nform
    fold!(prev, succ, tag, flip: true)
  end

  def is_percent?(prev : BaseNode, uzhi : BaseNode)
    if prev.is_a?(BaseList)
      body = prev.list.first
      return false unless body.nhanzis? && (succ = body.succ?)

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
