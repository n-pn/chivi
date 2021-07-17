module CV::Improving
  private def fix_by_key!(node : MtNode)
    case node.key
    when "对"
      if node.succ.try { |x| x.real? || x.quoteop? }
        node.update!("đối với", PosTag::Verb)
      else
        node.update!("đúng", PosTag::Adjt)
      end
    when "不对"
      if node.succ.try { |x| x.real? || x.quoteop? }
        node.update!("không đối với", PosTag::Verb)
      else
        node.update!("không đúng", PosTag::Adjt)
      end
    when "也"
      if boundary?(node.succ)
        node.update!("vậy", PosTag::Interjection)
      else
        node.update!("cũng", PosTag::Adverb)
      end
    when "原来"
      if node.succ.try(&.ude1?) || node.prev.try(&.real?)
        val = "ban đầu"
      else
        val = "thì ra"
      end
      node.update!(val)
    when "行"
      node.update!("được") if boundary?(node.succ)
    when "高达"
      node.update!("cao đến") if node.succ.try(&.number?)
    end
  end
end
