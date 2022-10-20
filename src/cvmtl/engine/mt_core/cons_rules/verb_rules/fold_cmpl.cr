module MT::Core
  def fold_cmpl!(cmpl : MtNode, verb = cmpl.prev)
    while verb.vcompl?
      verb = verb.prev
      verb = fix_mixedpos!(verb) if verb.is_a?(MonoNode) && verb.mixedpos?
    end

    raise "#{verb.inspect} is not verb!" unless verb.common_verbs?

    cmpl = verb.succ

    while cmpl = verb.succ?
      break unless cmpl.is_a?(MonoNode) && cmpl.vcompl?
      verb = pair_cmpl!(verb, cmpl)
    end

    verb
  end

  def pair_cmpl!(verb : MtNode, cmpl : MonoNode)
    tag = verb.tag
    pos = verb.pos

    # FIXME: fix combine verb with compelement
    PairNode.new(verb, cmpl, tag: tag, pos: pos)
  end
end
