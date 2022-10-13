module MT::AST::Rules
  def fold_atsign!(head : PunctWord, tail : MtNode) : MtNode
    key_io = String::Builder.new

    while tail && !tail.is_a?(PunctWord)
      key_io << tail.key
      tail = tail.succ?
    end

    return head unless tail.is_a?(PunctWord) && tail.flag.close_atsign?

    key = head.key + key_io.to_s
    val = CV::TextUtil.titleize(Engine.cv_hanviet(key, false))

    if tail.type.space?
      key += tail.key
      tail = tail.succ?
    end

    word = NounWord.new(key, val, idx: head.idx)
    word.set_prev(head.prev?)
    word.set_succ(tail)

    word
  end
end
