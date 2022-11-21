module MT::Rules
  def foldl_noun_expr!(noun : MtNode, prev = noun.prev) : MtNode
    if prev.ptcl_dep?
      return noun if !(head = prev.prev?) || head.punctuations?
      noun = foldl_objt_udep!(objt: noun, udep: prev, head: head)
      prev = noun.prev
    end

    while prev.join_word?
      return noun unless join = foldl_noun_join(noun, junc: prev)
      noun = join
      prev = noun.prev
    end

    return noun unless noun.all_nouns? || noun.maybe_noun?
    return fold_noun_pron!(noun, pron: prev) if prev.all_prons?

    if prev.maybe_quanti?
      prev.tag, prev.pos = PosTag.map_quanti(prev.as(MonoNode).key)
      prev.tap(&.fix_val!)
    elsif !prev.numerals?
      return noun
    end

    # puts [noun, prev, "noun_expr"]
    return noun if noun.succ.ptcl_dep? && !match_noun_quanti?(noun, quanti: prev)

    noun, prev = foldl_noun_number!(noun, prev: prev)
    prev.all_prons? ? fold_noun_pron!(noun, pron: prev) : noun
  end

  def foldl_noun_number!(noun : MtNode, prev : MtNode)
    fix_quanti_val!(quanti: prev, nominal: noun) unless prev.numbers?

    noun = NounExpr.new(noun) unless noun.is_a?(NounExpr)

    noun.add_nqmod(prev)
    head = noun.prev

    if prev.quantis? && head.ordinal?
      noun.add_nqmod(head)
      head = noun.prev
    end

    {noun, head}
  end

  def fix_quanti_val!(quanti : MtNode, nominal : MtNode) : Nil
    if quanti.nquants?
      return fix_nquant_val!(nquant: quanti, nominal: nominal) unless quanti.is_a?(PairNode)
      quanti = quanti.tail
    end

    case quanti = quanti.as(MonoNode)
    when .qt_ge4?
      quanti.val = ""
      quanti.pos |= MtlPos.flags(CapRelay, NoSpaceL, NoSpaceR, Skipover)
    when .qt_ba3?
      quanti.val =
        case nominal
        when .inhand? then "nắm"
        when .weapon? then "thanh"
        else               "chiếc"
        end
    end
  end

  def fix_nquant_val!(nquant : MtNode, nominal : MtNode) : Nil
    return unless nquant.is_a?(MonoNode)
    # FIXME: remove this from postag
    nquant.val = nquant.val.sub(" cái", "")
  end
end
