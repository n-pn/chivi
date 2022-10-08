module CV::TlRule
  def fold_atsign!(head : BaseNode)
    key_io = String::Builder.new

    tail = head
    while tail = tail.succ?
      break if tail.key == " "
      return head if tail.punctuations?
      key_io << tail.key
    end

    return head unless tail

    key = key_io.to_s
    val = TextUtil.titleize(MtCore.cv_hanviet(key, false))

    key = "#{head.key}#{key}#{tail.key}"

    if (prev = head.prev?) && prev.key == " "
      head = prev
      key = prev.key + key
    end

    tag = PosTag::CapHuman

    BaseTerm.new(key, "@#{val}", tag, dic: 2, idx: head.idx).tap do |new_node|
      new_node.fix_prev!(head.prev?)
      new_node.fix_succ!(tail.succ?)
    end
  end
end
