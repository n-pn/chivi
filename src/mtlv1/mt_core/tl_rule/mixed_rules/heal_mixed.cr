module CV::TlRule
  def heal_mixed!(node : MtNode, prev = node.prev, succ = node.succ?)
    return node unless node.is_a?(MtTerm)

    case node.tag
    when .vead? then heal_vead!(node, prev, succ)
    when .veno? then heal_veno!(node, prev, succ)
    when .ajno? then heal_ajno!(node, prev, succ)
    when .ajad? then heal_ajad!(node, prev, succ)
    else             node
    end
  end

  def heal_vead!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtTerm
    case succ
    when .nil?, .ends?, .nominal?
      MtDict.fix_verb!(node)
    when .aspect?, .vcompl?, .adverbial?
      MtDict.fix_adverb!(node)
    when .verbal?, .vmodals?, .preposes?, .adjective?
      MtDict.fix_adverb!(node)
    else
      MtDict.fix_verb!(node)
    end
  end

  def heal_ajad!(node : MtNode, prev : MtNode?, succ : MtNode?) : MtNode
    case succ
    when .nil?, .ends?, .nominal?
      MtDict.fix_adjt!(node)
    when .verbal?, .vmodals?, .preposes?, .adjective?, .adverbial?
      MtDict.fix_adverb!(node)
    else
      MtDict.fix_adjt!(node)
    end
  end

  private def not_verb_auxil?(node : MtNode)
    case node.tag
    when .ulian?, .uls?, .udh?, .uyy?, .udeng?, .usuo?
      true
    else
      false
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_veno!(node : MtTerm, prev : MtNode?, succ : MtNode?) : MtTerm
    # puts [node, prev, succ]

    case succ
    when .nil?, .ends?
      # to fixed by prev?
    when .aspect?, .vcompl?
      return MtDict.fix_verb!(node)
    when .v_shi?, .v_you?
      return MtDict.fix_noun!(node)
    when .nquants?
      return MtDict.fix_verb!(node) unless succ.nqtime?
    when .pronouns?, .verbal?, .pre_zai?, .number?
      return MtDict.fix_verb!(node)
      # when .nominal?
      #   node = MtDict.fix_verb!(node)
      #   return node unless node.vintr? || node.verb_object?
      #   MtDict.fix_noun!(node)
    end

    case prev
    when .nil?, .ends?
      return (succ && succ.nominal?) ? MtDict.fix_verb!(node) : node
    when .pro_dems?, .qtnoun?, .verbal?
      case succ
      when .nil?, .ends?, .auxils?
        return MtDict.fix_noun!(node)
      when .nominal?
        return succ.succ?(&.ude1?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
      when .ude1?
        return MtDict.fix_noun!(node)
      end
    when .pre_zai?, .pre_bei?, .vmodal?, .vpro?,
         .adverbial?, .ude2?, .ude3?, .object?
      return MtDict.fix_verb!(node)
    when .adjective?
      return MtDict.fix_verb!(node) unless prev.is_a?(MtTerm)
      return prev.modifier? ? MtDict.fix_noun!(node) : MtDict.fix_verb!(node)
    when .ude1?
      # TODO: check for adjt + ude1 + verb (grammar error)
      return prev.prev?(&.adverbial?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
    when .nhanzi?
      return prev.key == "一" ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
    when .preposes?
      return succ.try(&.nominal?) ? MtDict.fix_verb!(node) : MtDict.fix_noun!(node)
    end

    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_ajno!(node : MtNode, prev : MtNode?, succ : MtNode?) : MtNode
    # puts [node, prev, succ, "heal_ajno"]

    case succ
    when .nil?, .ends?
      return node if !prev || prev.ends?
      case prev
      when .nil?, .ends? then return node
      when .modi?, .pro_dems?, .quantis?, .nqnoun?
        return MtDict.fix_noun!(node)
      when .object?, .ude3?, .adjective?, .adverbial?
        return MtDict.fix_adjt!(node)
      when .conjunct?
        return prev.prev?(&.nominal?) ? MtDict.fix_adjt!(node) : node
      else
        return MtDict.fix_noun!(node)
      end
    when .vdir?
      return MtDict.fix_verb!(node)
    when .v_xia?, .v_shang?
      return MtDict.fix_noun!(node)
    when .ude1?, .ude2?, .ude3?, .mopart?
      return MtDict.fix_adjt!(node)
    when .verbal?, .preposes?
      return node.key.size > 2 ? MtDict.fix_noun!(node) : MtDict.fix_adjt!(node)
    when .nominal?, .spaces?
      node = MtDict.fix_adjt!(node)
      return node.set!(PosTag::Modi)
    else
      if succ.is_a?(MtTerm) && succ.key == "到"
        return MtDict.fix_adjt!(node)
      end
    end

    case prev
    when .nil?, .ends?, .adverbial?
      MtDict.fix_adjt!(node)
    when .modifier?
      MtDict.fix_noun!(node)
    else
      node
    end
  end
end
