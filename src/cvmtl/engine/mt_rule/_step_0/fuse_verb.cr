module MT::Core::Step0
  def fuse_verb!(verb : MonoNode)
    succ = verb.succ.as(MonoNode)

    case verb
    when .v_you? then return fuse_vyou!(verb, succ)
    when .v_shi? then return verb
    end

    if succ.key == verb.key
      # reduplication
      verb = PairNode.new(verb, succ)
      succ = verb.succ.as(MonoNode)
    end

    fuse_verb_cmpl!(verb, cmpl: succ)
  end

  def fuse_verb_cmpl!(verb : MtNode, cmpl : MonoNode)
    loop do
      case cmpl
      when .aspect_marker?
        return verb if verb.has_aspcmpl?

        pos = verb.pos | :has_aspcmpl
        pos |= :vlinking if cmpl.ptcl_zhe?

        verb = PairNode.new(verb, cmpl, verb.tag, pos: pos)
      when .adv_bu4?, .ptcl_der?
        # return verb if verb.has_dircmpl? || verb.has_rescmpl?
        tail = cmpl.succ.as(MonoNode)
        return verb unless tail.maybe_cmpl?

        cmpl.skipover! if cmpl.ptcl_der?
        tail.fix_val!

        pos = verb.pos | map_cmpl_pos(tail)
        verb = TrioNode.new(verb, cmpl, tail, verb.tag, pos: pos)
      when .maybe_cmpl?
        return verb if verb.has_dircmpl? || verb.has_rescmpl?

        cmpl.fix_val!
        pos = verb.pos | map_cmpl_pos(cmpl)
        verb = PairNode.new(verb, cmpl, verb.tag, pos: pos)
      else
        return verb
      end

      cmpl = verb.succ.as(MonoNode)
    end

    verb
  end

  private def map_cmpl_pos(cmpl : MonoNode)
    case cmpl
    when .shang_word?, .xia_word?
      MtlPos::HasDircmpl | MtlPos::HasRescmpl
    when .vdir?
      MtlPos::HasDircmpl
    else
      MtlPos::HasRescmpl
    end
  end

  def fuse_vyou!(vyou : MonoNode, succ : MonoNode)
    case succ
    when .nabst?, .nattr?
      tag, pos = PosTag.make(:amix)
      PairNode.new(vyou, succ, tag, pos)
    when .key?("些", "点")
      tail = succ.succ
      # FIXME: as more case here
      return vyou unless tail.adjt_words?
      tag, pos = PosTag.make(:amix)

      TrioNode.new(vyou, succ, tail, tag, pos)
    else
      vyou
    end
  end
end
