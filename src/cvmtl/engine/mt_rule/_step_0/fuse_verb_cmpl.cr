require "../../fix_dict/fix_cmpl"

module MT::Core::Step0
  def fuse_verb_cmpl!(verb : MtNode, cmpl : MonoNode) : {MtNode, MonoNode}
    case cmpl
    when .adv_bu4?, .ptcl_der?
      # return verb if verb.has_dircmpl? || verb.has_rescmpl?
      tail = cmpl.succ.as(MonoNode)

      case tail
      when .maybe_cmpl?
        fix_cmpl_val!(verb, cmpl) if verb.is_a?(MonoNode)
      when .adjt_words?
        tail = fuse_adjt!(tail)
      when .advb_words?, .maybe_advb?
        return {verb, cmpl} unless tail = fuse_advb_adjt(tail)
      else
        return {verb, cmpl}
      end

      cmpl.skipover! if cmpl.ptcl_der?

      pos = verb.pos | map_cmpl_pos(tail)
      verb = TrioNode.new(verb, cmpl, tail, verb.tag, pos: pos)
      {verb, verb.succ.as(MonoNode)}
    when .maybe_cmpl?
      return {verb, cmpl} if verb.has_dircmpl? || verb.has_rescmpl?

      fix_cmpl_val!(verb, cmpl) if verb.is_a?(MonoNode)
      pos = verb.pos | map_cmpl_pos(cmpl)
      verb = PairNode.new(verb, cmpl, verb.tag, pos: pos)
      {verb, verb.succ.as(MonoNode)}
    else
      {verb, cmpl}
    end
  end

  private def fix_cmpl_val!(verb : MonoNode, cmpl : MonoNode)
    wlen, cmpl_val, verb_val = FixCmpl.get(verb.key + cmpl.key)

    cmpl.val = cmpl_val if cmpl_val
    verb.val = verb_val if verb_val && verb.key.size == wlen
  end

  private def map_cmpl_pos(cmpl : MtNode)
    case cmpl
    when .shang_word?, .xia_word?
      MtlPos::HasDircmpl | MtlPos::HasRescmpl
    when .vdir?
      MtlPos::HasDircmpl
    else
      MtlPos::HasRescmpl
    end
  end
end
