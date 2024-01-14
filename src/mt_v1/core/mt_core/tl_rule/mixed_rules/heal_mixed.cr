module M1::TlRule
  def heal_mixed!(node : MtNode, prev = node.prev, succ = node.succ?)
    return node unless node.is_a?(MtDefn)
    succ = heal_mixed!(succ, prev: node) if succ && succ.polysemy?

    case node.tag
    when .vead? then heal_vead!(node, prev, succ)
    when .veno? then heal_veno!(node, prev, succ)
    when .ajno? then heal_ajno!(node, prev, succ)
    when .ajad? then heal_ajad!(node, prev, succ)
    else             node
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_vead!(node : MtDefn, prev : MtNode?, succ : MtNode?) : MtDefn
    return SpDict.fix_verbs.fix!(node) if succ.nil? || succ.ends?

    case succ
    when .vdir?, .adj_hao?
      return SpDict.fix_verbs.fix!(node)
    when .verbal?, .vmodals?, .preposes?, .adjective?
      return SpDict.fix_advbs.fix!(node)
    when .ude3?
      return succ.succ?(&.verbal?) ? SpDict.fix_advbs.fix!(node) : SpDict.fix_verbs.fix!(node)
    when .auxils?
      return SpDict.fix_verbs.fix!(node) unless not_verb_auxil?(succ)
    when .subject?
      return SpDict.fix_verbs.fix!(node)
    end

    case prev
    when .nil?       then node
    when .adverbial? then SpDict.fix_verbs.fix!(node)
    when .nhanzi?
      return node unless prev.is_a?(MtDefn)
      prev.key == "一" ? SpDict.fix_verbs.fix!(node) : node
    else node
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
  def heal_veno!(node : MtDefn, prev : MtNode?, succ : MtNode?) : MtDefn
    # puts [node, prev, succ]

    case succ
    when .nil?, .ends?, .ude1?
      # do nothing
    when .ule?
      return SpDict.fix_verbs.fix!(node) if succ.succ?(&.object?)
    when .auxils?
      return SpDict.fix_verbs.fix!(node) unless not_verb_auxil?(succ)
    when .v_shi?, .v_you?
      return SpDict.fix_nouns.fix!(node)
    when .nquants?
      return SpDict.fix_verbs.fix!(node) unless succ.nqtime?
    when .pronouns?, .verbal?, .pre_zai?, .number?
      return SpDict.fix_verbs.fix!(node)
      # when .nominal?
      #   node = SpDict.fix_verbs.fix!(node)
      #   return node unless node.vintr? || node.verb_object?
      #   SpDict.fix_nouns.fix!(node)
    end

    case prev
    when .nil?, .ends?
      return (succ && succ.nominal?) ? SpDict.fix_verbs.fix!(node) : node
    when .pro_dems?, .qtnoun?, .verbal?
      case succ
      when .nil?, .ends?, .auxils?
        return SpDict.fix_nouns.fix!(node)
      when .nominal?
        return succ.succ?(&.ude1?) ? SpDict.fix_verbs.fix!(node) : SpDict.fix_nouns.fix!(node)
      when .ude1?
        return SpDict.fix_nouns.fix!(node)
      end
    when .pre_zai?, .pre_bei?, .vmodal?, .vpro?,
         .adverbial?, .ude2?, .ude3?, .object?
      return SpDict.fix_verbs.fix!(node)
    when .adjective?
      return SpDict.fix_verbs.fix!(node) unless prev.is_a?(MtDefn)
      return prev.modifier? ? SpDict.fix_nouns.fix!(node) : SpDict.fix_verbs.fix!(node)
    when .ude1?
      # TODO: check for adjt + ude1 + verb (grammar error)
      return prev.prev?(&.adverbial?) ? SpDict.fix_verbs.fix!(node) : SpDict.fix_nouns.fix!(node)
    when .nhanzi?
      return prev.key == "一" ? SpDict.fix_verbs.fix!(node) : SpDict.fix_nouns.fix!(node)
    when .preposes?
      return succ.try(&.nominal?) ? SpDict.fix_verbs.fix!(node) : SpDict.fix_nouns.fix!(node)
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
        return SpDict.fix_nouns.fix!(node)
      when .object?, .ude3?, .adjective?, .adverbial?
        return SpDict.fix_adjts.fix!(node)
      when .conjunct?
        return prev.prev?(&.nominal?) ? SpDict.fix_adjts.fix!(node) : node
      else
        return SpDict.fix_nouns.fix!(node)
      end
    when .vdir?
      return SpDict.fix_verbs.fix!(node)
    when .v_xia?, .v_shang?
      return SpDict.fix_nouns.fix!(node)
    when .ude1?, .ude2?, .ude3?, .mopart?
      return SpDict.fix_adjts.fix!(node)
    when .verbal?, .preposes?
      return node.key.size > 2 ? SpDict.fix_nouns.fix!(node) : SpDict.fix_adjts.fix!(node)
    when .nominal?, .spaces?
      node = SpDict.fix_adjts.fix!(node)
      return node.set!(PosTag::Modi)
    else
      if succ.is_a?(MtDefn) && succ.key == "到"
        return SpDict.fix_adjts.fix!(node)
      end
    end

    case prev
    when .nil?, .ends?, .adverbial?
      SpDict.fix_adjts.fix!(node)
    when .modifier?
      SpDict.fix_nouns.fix!(node)
    else
      node
    end
  end

  def heal_ajad!(node : MtNode, prev : MtNode?, succ : MtNode?) : MtNode
    if succ && (succ.adjective? || succ.verbal? || succ.preposes? || succ.vmodals?)
      return SpDict.fix_advbs.fix!(node)
    end

    case prev
    when .nil?, .ends?, .adverbial?, .nominal?
      SpDict.fix_adjts.fix!(node)
    else
      node
    end
  end
end
