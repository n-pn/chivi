module CV::TlRule
  def fold_veno!(node : MtNode)
    node = heal_veno!(node)
    node.noun? ? fold_nouns!(node) : fold_verbs!(node)
  end

  def heal_veno!(node : MtNode)
    if prev = node.prev?
      # puts [node, prev, "heal_veno"]

      case prev
      when .ude1?
        return cast_verb!(node) if prev.prev?(&.adverbs?)
        return cast_noun!(node) unless (succ = node.succ?) && !(succ.ends?)
        return cast_noun!(node) if succ.nouns? || succ.junction?
      when .adverbs?, .vmodals?, .vpro?, .pre_zai?, .pre_bei?
        return cast_verb!(node)
      when .auxils?, .preposes?, .modifier?
        return cast_noun!(node)
        # when .numeric?
        #   if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
        #     return cast_noun!(node)
        #   end
      when .junction?
        return cast_verb!(node) if prev.key == "而"

        prev.prev? do |prev_2|
          return cast_noun!(node) if prev_2.nouns?
          return cast_verb!(node) if prev_2.verbs?
        end
      when .pro_dems?, .qtnoun?
        case succ = node.succ?
        when .nil?, .ends?
          return cast_noun!(node)
        when .nouns?
          return cast_verb!(node)
        when .ude1?
          if {"扭曲"}.includes?(node.key)
            return node.set!(PosTag::Vintr)
          end
        end
      when .verb?
        return cast_noun!(node) if node.succ?(&.ude1?)
      end
    end

    case succ = node.succ?
    when .nil? then node
    when .auxils?, .vdir?, .pre_zai?
      cast_verb!(node)
    else node
    end
  end
end
