module MT::Core
  def fold_cmpl!(cmpl : MtNode)
    # puts [cmpl, cmpl.tag, cmpl.pos, cmpl.prev?]

    verb = cmpl
    while verb = verb.prev
      verb = fix_mixedpos!(verb) if verb.mixedpos?
      break unless verb.vcompl?
    end

    raise "#{verb.inspect} is not verb!" unless verb.common_verbs?

    while cmpl = verb.succ
      break unless cmpl.vcompl?
      verb = pair_cmpl!(verb, cmpl)
    end

    fold_verb!(verb)
  end

  def pair_cmpl!(verb : MtNode, cmpl : MtNode)
    tag = verb.tag
    pos = verb.pos

    # FIXME: fix combine verb with compelement
    PairNode.new(verb, cmpl, tag: tag, pos: pos)
  end
end
