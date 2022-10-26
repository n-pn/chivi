module MT::Core
  def make_noun_cons!(noun : MtNode) : MtNode
    noun = pair_noun!(noun)
    prev = noun.prev

    prev = fix_mixedpos!(prev) if prev.mixedpos?

    return noun if noun_is_modifier?(noun, prev)

    noun = NounCons.new(noun) unless noun.is_a?(NounCons)

    if prev.ptcl_deps?
      dpmod = join_udep!(udep: prev)
      noun.add_dpmod(dpmod)

      prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?
    end

    noun, prev = fold_noun_number!(noun, number: prev) if prev.numerals?

    return noun if !prev.all_prons? || prev.per_prons?

    # FIXME: handle special pronoun cases
    noun.add_pdmod(prev)
    # if prev.dem_prons? || prev.pro_na2?
    #   noun = PairNode.new(prev, noun, flip: prev.at_tail?)
    #   return noun unless prev = noun.prev?
    # end

    noun
  end

  def fold_noun_number!(noun : NounCons, number : MtNode)
    fix_quanti_val!(quanti: number, nominal: noun.noun) unless number.numbers?

    noun.add_nqmod(number)
    prev = noun.prev

    if number.quantis? && prev.ordinal?
      noun.add_nqmod(prev)
      prev = noun.prev
    end

    {noun, prev}
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
