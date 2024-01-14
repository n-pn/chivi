require "../sp_dict"

module M1::MTL
  extend self

  def fix_postag(node : MtNode)
    while node = node.prev?
      case node
      when .polysemy? then fix_polysemy(node)
      else                 node
      end
    end
  end

  def fix_polysemy(node : MtNode)
    prev = prev_node(node)
    succ = succ_node(node)

    case node.tag
    when .vead? then fix_vead(node, prev, succ)
    when .veno? then fix_veno(node, prev, succ)
    when .ajno? then fix_ajno(node, prev, succ)
    when .ajad? then fix_ajad(node, prev, succ)
    else             node
    end
  end

  def prev_node(node : MtNode)
    return unless prev = node.prev?
    prev.quoteop? ? prev.prev? : prev
  end

  def succ_node(node : MtNode)
    return unless succ = node.succ?
    succ.quotecl? ? succ.succ? : succ
  end

  def fix_vead(node, prev, succ)
    case succ
    when .nil?, .ends?, .nominal?
      SpDict.fix_verbs.fix!(node)
    when .aspect?, .vcompl?
      SpDict.fix_advbs.fix!(node)
    when .verbal?, .vmodals?, .preposes?, .adjective?
      SpDict.fix_advbs.fix!(node)
    else
      SpDict.fix_verbs.fix!(node)
    end
  end

  def fix_ajad(node, prev, succ)
    case succ
    when .verbal?, .vmodals?, .preposes?, .adjective?
      SpDict.fix_advbs.fix!(node)
    else
      SpDict.fix_adjts.fix!(node)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fix_veno(node, prev, succ) : MtDefn
    # puts [node, prev, succ]

    case succ
    when .nil?, .ends?
      # to fixed by prev?

    when .aspect?, .vcompl?
      return SpDict.fix_verbs.fix!(node)
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
end
