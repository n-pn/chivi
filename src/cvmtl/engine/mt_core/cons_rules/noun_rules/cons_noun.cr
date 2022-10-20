module MT::Core
  def cons_noun!(noun : MtNode) : MtNode
    noun = pair_noun!(noun)
    prev = noun.prev

    prev = fix_mixedpos!(prev) if prev.mixedpos?
    return noun if noun_is_modifier?(noun, prev)

    noun = NounCons.new(noun) unless noun.is_a?(NounCons)

    if prev.pt_deps?
      dpmod = join_udep!(udep: prev)
      noun.add_dpmod(dpmod)

      prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?
    end

    noun, prev = fold_noun_number!(noun, prev) if prev.numqti_words?
    return noun if !prev.pronouns? || prev.pro_pers?

    # FIXME: handle special pronoun cases
    noun.add_pdmod(prev)
    # if prev.pro_dems? || prev.pro_na2?
    #   noun = PairNode.new(prev, noun, flip: prev.at_tail?)
    #   return noun unless prev = noun.prev?
    # end
  end

  def fold_noun_number!(noun : NounCons, number : MtNode)
    case number
    when .quantis?
      nmod = fold_quanti!(number)
      noun.add_nqmod(nmod)
      prev = noun.prev

      if prev.ordinal?
        noun.add_nqmod(prev)
        prev = noun.prev
      end
    else
      # return {noun. prev} unless number.numqti_words?
      noun.add_nqmod(noun)
      prev = noun.prev
    end

    {noun, prev}
  end
end
