module CV::TlRule
  def heal_mixed!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return node unless node.is_a?(MtTerm)

    case node.tag
    when .pl_vead? then heal_vead!(node, prev, succ)
    when .pl_veno? then heal_veno!(node, prev, succ)
    when .pl_ajno? then heal_ajno!(node, prev, succ)
    when .pl_ajad? then heal_ajad!(node, prev, succ)
    else                node
    end
  end

  def heal_vead!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtTerm
    case succ
    when .nil?, .boundary?, .nominal?
      node.as_verb!(nil)
    when .aspect?, .vcompl?, .advbial?
      node.as_advb!
    when .verbal?, .vmodals?, .preposes?, .adjts?
      node.as_advb!
    else
      node.as_verb!(nil)
    end
  end

  def heal_ajad!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtNode
    case succ
    when .nil?, .boundary?, .nominal?
      node.as_adjt!(nil)
    when .verbal?, .vmodals?, .preposes?, .adjts?, .advbial?
      node.as_advb!
    else
      node.as_adjt!(nil)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_veno!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtTerm
    # puts [node, prev, succ]

    case succ
    when .nil?, .boundary?
      # to fixed by prev?
    when .aspect?, .vcompl?
      return node.as_verb!(nil)
    when .v_shi?, .v_you?
      return node.as_noun!
    when .nquants?
      return node.as_verb!(nil) unless succ.nqtime?
    when .pronouns?, .verbal?, .pre_zai?, .numbers?
      return node.as_verb!(nil)
      # when .nominal?
      #   node = node.as_verb!(nil)
      #   return node unless node.vintr? || node.verb_object?
      #   node.as_noun!
    end

    case prev
    when .nil?, .boundary?
      return (succ && succ.nominal?) ? node.as_verb!(nil) : node
    when .pro_dems?, .qtnoun?, .verbal?
      case succ
      when .nil?, .boundary?, .particles?
        return node.as_noun!
      when .nominal?
        return succ.succ?(&.ude1?) ? node.as_verb!(nil) : node.as_noun!
      when .ude1?
        return node.as_noun!
      end
    when .pre_zai?, .pre_bei?, .vmodal?, .vpro?,
         .advbial?, .ude2?, .ude3?, .object?
      return node.as_verb!(nil)
    when .adjts?
      return node.as_verb!(nil) unless prev.is_a?(MtTerm)
      return prev.modifier? ? node.as_noun! : node.as_verb!(nil)
    when .ude1?
      # TODO: check for adjt + ude1 + verb (grammar error)
      return prev.prev?(&.advbial?) ? node.as_verb!(nil) : node.as_noun!
    when .nhanzi?
      return prev.key == "一" ? node.as_verb!(nil) : node.as_noun!
    when .preposes?
      return succ.try(&.nominal?) ? node.as_verb!(nil) : node.as_noun!
    end

    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_ajno!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtNode
    # puts [node, prev, succ, "heal_ajno"]

    case succ
    when .nil?, .boundary?
      return node if !prev || prev.boundary?
      case prev
      when .nil?, .boundary? then return node
      when .modi?, .pro_dems?, .quantis?, .nqnoun?
        return node.as_noun!
      when .object?, .ude3?, .adjts?, .advbial?
        return node.as_adjt!(nil)
      when .conjunct?
        return prev.prev?(&.nominal?) ? node.as_adjt!(nil) : node
      else
        return node.as_noun!
      end
    when .vdir?
      return node.as_verb!(nil)
    when .v_xia?, .v_shang?
      return node.as_noun!
    when .ude1?, .ude2?, .ude3?, .mopart?
      return node.as_adjt!(nil)
    when .verbal?, .preposes?
      return node.key.size > 2 ? node.as_noun! : node.as_adjt!(nil)
    when .nominal?, .spaces?
      node = node.as_adjt!(nil)
      return node.set!(PosTag::Modi)
    else
      if succ.is_a?(MtTerm) && succ.key == "到"
        return node.as_adjt!(nil)
      end
    end

    case prev
    when .nil?, .boundary?, .advbial?
      node.as_adjt!(nil)
    when .modifier?
      node.as_noun!
    else
      node
    end
  end
end
