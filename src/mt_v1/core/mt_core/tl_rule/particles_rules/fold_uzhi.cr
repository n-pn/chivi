module M1::TlRule
  def fold_uzhi!(uzhi : MtNode, prev : MtNode = uzhi.prev, succ = uzhi.succ?) : MtNode
    return prev if !succ || succ.ends?
    uzhi.val = ""

    if succ.nhanzi? && is_percent?(prev, uzhi)
      # TODO: handle this in fold_number!
      tag = PosTag::Number
    elsif succ.is_a?(MtDefn)
      unless tag = SpDict.fix_u_zhi.fix_uzhi(succ)
        return prev if succ.adjt?
      end
    end

    tag ||= PosTag::Nform
    fold!(prev, succ, tag, dic: 3, flip: true)
  end

  def is_percent?(prev : MtNode, uzhi : MtNode)
    if prev.is_a?(MtList)
      body = prev.list.first
      return false unless body.nhanzi? && (succ = body.succ?)

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
