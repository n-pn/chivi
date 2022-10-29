module MT::Rules
  def foldl_verb_join!(verb : MtNode, join = verb.prev, head = join.prev)
    # FIXME:
    # - handle foldl_noun_full result can be subject + verb phrase
    # - join verb with adjt?

    case head
    when .common_verbs?
      head = foldl_verb_expr!(head)
    when .noun_words?
      head = foldl_noun_full!(head)
    else
      return verb
    end

    tag = MtlTag::Vmix
    pos = head.pos | verb.pos

    TrioNode.new(head, join, verb, tag: tag, pos: pos)
  end
end
