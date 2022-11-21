module MT::Rules
  def foldr_verb_base!(verb : MonoNode)
    succ = verb.succ.as(MonoNode)

    case verb
    when .v_you? then return foldr_vyou_base!(verb, succ)
    when .v_shi? then return verb
    end

    # reduplication
    verb, succ = foldr_verb_redup!(verb, succ)
    verb, succ = foldr_verb_cmpl!(verb, cmpl: succ)

    # fuse verb with aspect marker
    return verb if !succ.aspect_marker? || verb.has_aspcmpl?

    pos = verb.pos | :has_aspcmpl
    pos |= :vlinking if succ.ptcl_zhe?

    PairNode.new(verb, succ, verb.tag, pos: pos)
  end

  def foldr_verb_redup!(verb : MonoNode, succ : MonoNode)
    if succ.ptcl_le?
      tail = succ.succ.as(MonoNode)
      return {verb, succ} if verb.prev?(&.ptcl_le?) || !is_verb_redup?(verb, tail)

      succ.skipover!
      pos = tail.pos | :has_aspcmpl

      verb = TrioNode.new(verb, succ, tail, tail.tag, pos)
      {verb, verb.succ.as(MonoNode)}
    elsif is_verb_redup?(verb, succ)
      verb = PairNode.new(verb, succ, succ.tag, succ.pos)
      {verb, verb.succ.as(MonoNode)}
    else
      {verb, succ}
    end
  end

  private def is_verb_redup?(head : MonoNode, tail : MonoNode) : Bool
    tail.key == head.key || tail.key[0, 1] == head.key
  end
end
