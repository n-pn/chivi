module MT::Core
  def pair_verb!(verb : MtNode, prev = verb.prev)
    return verb unless prev.is_a?(MonoNode)

    if (prev.common_verbs? && verb.is_a?(MonoNode) && verb.key == prev.key)
      pos = verb.pos | MtlPos::Redup
      verb = PairNode.new(prev, verb, verb.tag, pos)
      prev = verb.prev
      return verb unless prev.is_a?(MonoNode)
    end

    case prev
    when .pt_suo?
      prev.val = "chỗ"
    when .pre_jiang?, .pre_zai?, .pre_bei?
      return verb unless prepos_is_vauxil?(verb, prev)
      prev.swap_val!
      # TODO: change meaning of pre_zai and pre_bei
    when .pt_der?
      prev.tag = MtlTag::Vmod
      prev.val = "phải"
      prev.pos |= MtlPos::Desire
    when .verb_take_verb?
      prev.val = fix_vauxil_val!(verb: verb, auxil: prev)
      prev.swap_val! # switch to alternative meaning
    else
      return verb
    end

    verb = VerbCons.new(verb) unless verb.is_a?(VerbCons)
    prev.pos |= MtlPos::Vauxil
    verb.pos |= MtlPos::Desire if prev.pos.desire?
    verb.add_auxi(prev)
    verb
  end

  def prepos_is_vauxil?(verb : MtNode, prepos : MtNode)
    case prepos.prev
    when .mark_noun_after?
      # prepos is a part of verb
      true
    else
      # FIXME: check if verb is a part of noun
      true
    end
  end

  def fix_vauxil_val!(verb : MtNode, auxil : MonoNode) : String
    case auxil
    when .vm_hui?
      return "biết" if verb_is_skill?(verb)
      auxil.prev? { |x| x.pos |= MtlPos::AtTail if x.adv_bu4? }
      "sẽ"
    when .vm_xiang? then "muốn"
    when .vm_yao?   then "cần"
    else                 auxil.alt || auxil.val
    end
  end

  def verb_is_skill?(verb : MtNode)
    return true if verb.vset?
    verb.verb_take_obj? && verb.succ?(&.object?)
  end
end
