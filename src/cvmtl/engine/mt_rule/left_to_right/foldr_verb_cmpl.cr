require "../../fix_dict/fix_cmpl"

module MT::Rules::LTR
  def foldr_verb_cmpl!(verb : MtNode, cmpl : MonoNode) : {MtNode, MonoNode}
    case cmpl
    when .adv_bu4?, .ptcl_der?
      foldr_verb_cmpl_infix!(verb, infix: cmpl)
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

  def foldr_verb_cmpl_infix!(verb, infix, cmpl = infix.succ.as(MonoNode))
    # return {verbv, infix} if verb.has_dircmpl? || verb.has_rescmpl?

    case cmpl
    when .maybe_cmpl?
      fix_cmpl_val!(verb, cmpl) if verb.is_a?(MonoNode)
    when .adjt_words?
      cmpl = foldr_adjt_base!(cmpl)
    when .advb_words?, .maybe_advb?
      return {verb, infix} unless cmpl = foldr_advb_adjt(cmpl)
    else
      return {verb, infix}
    end

    infix.skipover! if infix.ptcl_der?

    pos = verb.pos | map_cmpl_pos(cmpl)
    verb = TrioNode.new(verb, infix, cmpl, verb.tag, pos: pos)

    {verb, verb.succ.as(MonoNode)}
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
