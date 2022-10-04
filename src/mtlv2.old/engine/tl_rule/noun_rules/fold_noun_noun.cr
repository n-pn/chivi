module MtlV2::TlRule
  @[Flags]
  enum NounMode
    NoLocat # if before of noun still remains potential combinable node
    NoUde1  # do not fold noun with ude1
    FoldAll
    VerbTwo
    LinkingVerb

    def self.init(noun : BaseNode, prev = noun.prev?) : self
      mode = FoldAll
      return mode unless prev

      if prev.adjective?
        mode |= NoLocat
        return mode unless prev = prev.prev?
      end

      if prev.numeral?
        mode |= NoLocat
        return mode unless prev = prev.prev?
      end

      if prev.pro_dems? || prev.pro_ints?
        mode |= NoLocat
        return mode unless prev = prev.prev?
      end

      # puts [noun, prev, "init_noun_fold_mode"]

      case prev
      when .preposes? then mode.with_prepos(noun, prev)
      when .verbal?   then mode.with_verbal(noun, prev)
      when .pt_dep?   then mode.with_ude1(noun, prev)
      else                 mode
      end
    end

    def with_prepos(noun : BaseNode, prepos : BaseNode)
      # TODO: check prepos + noun as defn phrase
      self
    end

    def with_verbal(noun : BaseNode, verb : BaseNode)
      # TODO: add checks for v_you
      return self if verb.v_shi?

      if verb.v_you?
        return self unless verb.prev?(&.verbal?)
      end

      mode = self
      mode |= VerbTwo if verb.tag.v2_object?
      # mode |= LinkingVerb if verb.is_linking_verb?

      return mode if verb.flag.has_uzhe? || verb.key.in?("按照")
      return mode if !(prev = verb.prev?) || prev.comma?

      case verb.prev?
      when .nil?, .ends?, .verbal?, .numeral?, .pro_dems?
        mode |= NoUde1
      end

      # puts [mode, verb, verb.prev?]
      mode
    end

    def with_ude1(node : BaseNode, ude1 : BaseNode)
      return self if !(prev = ude1.prev?) || prev.ends?
      # TODO: check for deep prev
      self | NoLocat
    end
  end

  def noun_is_subject?(noun : BaseNode)
    return false if !(succ = noun.succ?) || succ.ends?
    succ = fold_adverbs!(succ) if succ.adverbial?
    return succ.adjective? unless succ.verbal?
    !succ.v_shi? && !succ.v_you?
  end

  def fold_noun_noun!(node : BaseNode, succ : BaseNode, mode : NounMode) : BaseNode
    case succ.tag
    when .ptitle?
      if node.names? || node.ptitle?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold!(node, succ, PosTag::Person, dic: 3, flip: true)
      end
    when .affil?
      fold!(node, succ, succ.tag, dic: 4, flip: node.affil?)
    when .names?
      fold!(node, succ, succ.tag, dic: 4, flip: false)
    when .position?
      fold!(node, succ, succ.tag, dic: 3, flip: true)
    else
      flip = !mode.verb_two? || succ.succ?(&.subject?) || false
      ptag = flip ? succ.tag : PosTag::Noun
      fold!(node, succ, ptag, dic: 3, flip: flip)
    end
  end

  # # ameba:disable Metrics/CyclomaticComplexity
  # def noun_can_combine?(prev : BaseNode?, succ : BaseNode?) : Bool
  #   while prev && (prev.numeral? || prev.pronouns?)
  #     # puts [prev, succ, "noun_can_combine"]
  #     prev = prev.prev?
  #   end

  #   return true if !prev || prev.preposes?
  #   return true if !succ || succ.subject? || succ.ends? || succ.v_shi? || succ.v_you?

  #   # puts [prev, succ, "noun_can_combine"]
  #   case succ
  #   when .maybe_adjt?
  #     return false unless (tail = succ.succ?) && tail.pt_dep?
  #     tail.succ? { |x| x.ends? || x.verbal? } || false
  #   when .preposes?, .verbal?
  #     return true if succ.succ? { |x| x.pt_dep? || x.ends? }
  #     return false if prev.ends?
  #     false
  #     # is_linking_verb?(prev, succ)
  #   else
  #     true
  #   end
  # end
end
