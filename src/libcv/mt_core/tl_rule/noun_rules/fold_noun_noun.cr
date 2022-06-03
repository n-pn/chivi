module CV::TlRule
  @[Flags]
  enum NounMode
    NoLocality # if before of noun still remains potential combinable node
    NoUde1     # do not fold noun with ude1
    FoldAll
    VerbTwo
    LinkingVerb

    def self.init(noun : MtNode, prev = noun.prev?) : self
      mode = FoldAll
      return mode unless prev

      if prev.adjective?
        mode |= NoLocality
        return mode unless prev = prev.prev?
      end

      if prev.numeral?
        mode |= NoLocality
        return mode unless prev = prev.prev?
      end

      if prev.pro_dems? || prev.pro_ints?
        mode |= NoLocality
        return mode unless prev = prev.prev?
      end

      case prev
      when .preposes? then mode.with_prepos(noun, prev)
      when .verbal?   then mode.with_verbal(noun, prev)
      when .ude1?     then mode.with_verbal(noun, prev)
      else                 mode
      end
    end

    def with_prepos(noun : MtNode, prepos : MtNode)
      # TODO: check prepos + noun as defn phrase
      self
    end

    def with_verbal(noun : MtNode, verb : MtNode)
      # TODO: add checks for v_you
      return self if verb.v_shi? || verb.v_you?

      mode = self
      mode |= VerbTwo if verb.tag.v2_object?
      # mode |= LinkingVerb if verb.is_linking_verb?

      case verb.prev?
      when .nil?, .ends?, .verbal?, .numeral?, .pro_dems?
        mode |= NoUde1
      end

      mode
    end

    def with_ude1(node : MtNode, ude1 : MtNode)
      return self if !(prev = ude1.prev?) || prev.ends?
      # TODO: check for deep prev
      self | NoLocality
    end
  end

  def noun_is_subject?(noun : MtNode)
    return false if !(succ = noun.succ?) || succ.ends?
    succ = fold_adverbs!(succ) if succ.adverbial?
    return succ.adjective? unless succ.verbal?
    !succ.v_shi? && !succ.v_you?
  end

  def fold_noun_noun!(node : MtNode, succ : MtNode, mode : NounMode) : MtNode
    case succ.tag
    when .ptitle?
      if node.names? || node.ptitle?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold!(node, succ, PosTag::Person, dic: 3, flip: true)
      end
    when .names?
      fold!(node, succ, succ.tag, dic: 4)
    when .position?
      fold!(node, succ, PosTag::DefnPhrase, dic: 3, flip: true)
    else
      flip = mode.verb_two? && !(succ.succ?(&.subject?))
      ptag = flip ? succ.tag : PosTag::Noun
      fold!(node, succ, ptag, dic: 3, flip: flip)
    end
  end

  # # ameba:disable Metrics/CyclomaticComplexity
  # def noun_can_combine?(prev : MtNode?, succ : MtNode?) : Bool
  #   while prev && (prev.numeral? || prev.pronouns?)
  #     # puts [prev, succ, "noun_can_combine"]
  #     prev = prev.prev?
  #   end

  #   return true if !prev || prev.preposes?
  #   return true if !succ || succ.subject? || succ.ends? || succ.v_shi? || succ.v_you?

  #   # puts [prev, succ, "noun_can_combine"]
  #   case succ
  #   when .maybe_adjt?
  #     return false unless (tail = succ.succ?) && tail.ude1?
  #     tail.succ? { |x| x.ends? || x.verbal? } || false
  #   when .preposes?, .verbal?
  #     return true if succ.succ? { |x| x.ude1? || x.ends? }
  #     return false if prev.ends?
  #     false
  #     # is_linking_verb?(prev, succ)
  #   else
  #     true
  #   end
  # end
end
