module CV::TlRule
  def fold_veno!(node : MtNode)
    node = heal_veno!(node)
    node.noun? ? fold_nouns!(node) : fold_verbs!(node)
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
    when .adverbial?, .vmodals?, .vpro?, .pre_zai?, .pre_bei?
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
      return node unless node.vintr? || node.verb_object?
      MtDict.fix_noun!(node)
    when .auxils?, .vdir?, .pre_zai?
      MtDict.fix_verb!(node)
    when .v_shi?, .v_you?
      MtDict.fix_noun!(node)
    when .verbal?
      return node.set!(PosTag::Vpro) if node.key == "选择"

      if MtDict.has_key?(:v_compl, succ.key) || VERB_COMBINE.includes?(node.key)
        MtDict.fix_verb!(node)
      else
        MtDict.fix_noun!(node)
      end
    else node
    end
  end
end