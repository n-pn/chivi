module CV::TlRule
  def meld_mixed!(node : MtNode) : MtNode
    case node.tag
    when .veno? then node = heal_veno!(node)
    when .vead? then node = heal_vead!(node)
    when .ajno? then node = heal_ajno!(node)
    when .ajad? then node = heal_ajad!(node)
      # when .adv_noun? then fold_adv_noun!(node)
    end

    case node
    when .adverb?    then fold_adverb_base!(node)
    when .adjective? then fold_adjts!(node)
    when .verbal?    then fuse_verb!(node)
    when .nominal?   then fuse_noun!(node)
    else                  node
    end
  end

  def heal_ajad!(node : MtNode, succ = node.succ) : MtNode
    if mixed_is_adverb?(node, succ)
      MtDict.fix_adverb!(node)
    else
      MtDict.fix_adjt!(node)
    end
  end

  def heal_vead!(node : MtNode) : MtNode
    case succ = node.succ?
    when .nil?, .ends?
      return MtDict.fix_verb!(node)
    when .veno?
      succ = heal_veno!(succ)
      return succ.nominal? ? MtDict.fix_verb!(node) : MtDict.fix_adverb!(node)
    when .verbal?, .vmodals?, .preposes?
      return MtDict.fix_verb!(node)
    when .nominal?, .numeral?, .pronouns?
      return MtDict.fix_verb!(node)
    end

    case prev = node.prev?
    when .nil?    then node
    when .adverb? then MtDict.fix_verb!(node)
    when .nhanzi?
      prev.key == "一" ? MtDict.fix_verb!(node) : node
    else node
    end
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  def heal_ajno!(node : MtNode)
    case node.prev?
    when .nil?
    when .adverbial?
      return MtDict.fix_adjt!(node)
    when .modi?
      return MtDict.fix_noun!(node)
    end

    # puts [node, node.prev?, node.succ?]
    case succ = node.succ?
    when .nil?, .puncts?
      if node.prev?(&.object?)
        MtDict.fix_adjt!(node)
      else
        MtDict.fix_noun!(node)
      end
    when .verbal?, .preposes?, .none?, .spaces?
      MtDict.fix_noun!(node)
    when .noun?
      node.set!(PosTag::Modi)
    when .ude1?, .mopart?
      MtDict.fix_adjt!(node)
    else
      if {"到"}.includes?(succ.key)
        MtDict.fix_adjt!(node)
      else
        node
      end
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_veno!(node : MtNode, succ = node.succ?)
    # puts [node, prev, "heal_veno"]

    case prev = node.prev?
    when .nil?
      # nothing
    when .ude1?
      case prev.prev?
      when .nil?       then return node
      when .adverbial? then return MtDict.fix_verb!(node)
        # TODO: check for adjt + ude1 + verb (grammar error)
      else return MtDict.fix_noun!(node)
      end
    when .nhanzi?
      return MtDict.fix_verb!(node) if prev.key == "一"
    when .adverbial?, .vmodals?, .pre_zai?, .pre_bei?
      return MtDict.fix_verb!(node)
    when .auxils?, .preposes?, .modi?
      return MtDict.fix_noun!(node)
      # when .numeral?
      #   if (succ = node.succ?) && !(succ.nominal? || succ.pronouns?)
      #     return MtDict.fix_noun!(node)
      #   end
    when .junction?
      return MtDict.fix_verb!(node) if prev.key == "而"

      prev.prev? do |prev_2|
        return MtDict.fix_noun!(node) if prev_2.nominal?
        return MtDict.fix_verb!(node) if prev_2.verbal?
      end
    when .pro_dems?, .qtnoun?
      case node.succ?
      when .nil?, .ends?
        return MtDict.fix_noun!(node)
      when .nominal?
        return MtDict.fix_verb!(node)
      when .ude1?
        if {"扭曲"}.includes?(node.key)
          return node.set!(PosTag::Vintr)
        end
      end
    when .subject?
      return MtDict.fix_verb!(node) if prev.prev?(&.preposes?)
    when .verb?
      return MtDict.fix_noun!(node) if node.succ?(&.ude1?)
    end

    case succ = node.succ?
    when .nil? then node
    when .penum?
      case tail = succ.succ?
      when .nil? then node
      when .veno?, .nominal?, .verbal?
        tail = heal_veno!(tail)
        fold!(node, tail, tail.tag, dic: 4)
      else
        node
      end
    when .pronouns?
      MtDict.fix_verb!(node)
    when .nominal?
      node = MtDict.fix_verb!(node)
      return node unless node.v0_obj?
      MtDict.fix_noun!(node)
    when .auxils?, .pre_zai?
      MtDict.fix_verb!(node)
    when .v_shi?, .v_you?
      MtDict.fix_noun!(node)
    when .v_dircomp?
      MtDict.fix_verb!(node)
    when .verbal?
      if node.key == "选择"
        node.set!(PosTag::VCombine)
      else
        MtDict.fix_noun!(node)
      end
    else node
    end
  end

  private def mixed_is_adverb?(node : MtNode, succ : MtNode) : Bool
    return true if succ.adjective? || succ.preposes? || succ.verbal? || succ.vmodals?
    false
  end
end
