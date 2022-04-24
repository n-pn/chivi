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
      when .nil?     then return node
      when .adverbs? then return MtDict.fix_verb!(node)
        # TODO: check for adjt + ude1 + verb (grammar error)
      else return MtDict.fix_noun!(node)
      end
    when .adverbs?, .vmodals?, .vpro?, .pre_zai?, .pre_bei?
      return MtDict.fix_verb!(node)
    when .auxils?, .preposes?, .modifier?
      return MtDict.fix_noun!(node)
      # when .numeric?
      #   if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
      #     return MtDict.fix_noun!(node)
      #   end
    when .junction?
      return MtDict.fix_verb!(node) if prev.key == "而"

      prev.prev? do |prev_2|
        return MtDict.fix_noun!(node) if prev_2.nouns?
        return MtDict.fix_verb!(node) if prev_2.verbs?
      end
    when .pro_dems?, .qtnoun?
      case node.succ?
      when .nil?, .ends?
        return MtDict.fix_noun!(node)
      when .nouns?
        return MtDict.fix_verb!(node)
      when .ude1?
        if {"扭曲"}.includes?(node.key)
          return node.set!(PosTag::Vintr)
        end
      end
    when .verb?
      return MtDict.fix_noun!(node) if node.succ?(&.ude1?)
    end

    case succ = node.succ?
    when .nil? then node
    when .pronouns?
      MtDict.fix_verb!(node)
    when .nouns?
      node = MtDict.fix_verb!(node)
      return node unless node.vintr? || node.verb_object?
      MtDict.fix_noun!(node)
    when .auxils?, .vdir?, .pre_zai?
      MtDict.fix_verb!(node)
    when .v_shi?, .v_you?
      MtDict.fix_noun!(node)
    when .verbs?
      if MtDict.has_key?(:v_compl, succ.key) || VERB_COMBINE.includes?(node.key)
        MtDict.fix_verb!(node)
      else
        MtDict.fix_noun!(node)
      end
    else node
    end
  end
end
