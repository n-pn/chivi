module CV::TlRule
  def fold_veno!(node : MtNode)
    node = heal_veno!(node)
    node.noun? ? fold_noun!(node) : fold_verbs!(node)
  end

  def heal_veno!(node : MtNode)
    if prev = node.prev?
      case prev
      when .auxils?, .preposes?
        return cast_noun!(node)
      when .adverbs?, .vmodals?, .vpro?
        return cast_verb!(node)
        # when .numeric?
        #   if (succ = node.succ?) && !(succ.nouns? || succ.pronouns?)
        #     return cast_noun!(node)
        #   end
      when .pro_dems?, .qtnoun?
        unless node.succ?(&.nouns?)
          return cast_noun!(node)
        end
      when .verb?
        return cast_noun!(node) if node.succ?(&.ude1?)
      when .ude1?
        if node.succ? { |x| x.ends? || x.nouns? }
          cast_noun!(node)
        end
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
