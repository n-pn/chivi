module MT::TlRule
  def fold_noun_left!(noun : MtNode, level = 0) : MtNode
    while prev = noun.prev?
      case prev
      when .pl_veno?, .pl_ajno?
        prev = heal_mixed!(prev)
      when .locat?, .posit?
        prev = fold_noun_left!(prev, level: 1)
      end

      break unless prev.noun_words?
      noun = fold_noun_noun_left!(noun, prev)
    end

    level == 0 && prev ? fold_noun_left_2!(noun) : noun
  end

  def fold_noun_left_2!(noun : MtNode, prev = noun.prev) : MtNode
    ptag = noun.tag.posit? ? noun.tag : MapTag::Nform

    if prev.adjt_words?
      noun = fold_noun_adjt_left!(noun, prev)
      return noun unless prev = noun.prev?
    end

    if prev.quantis? || prev.nquants?
      prev.val = "" if prev.key == "个"
      noun = fold!(prev, noun, ptag, flip: false)
      return noun unless prev = noun.prev?
    end

    if prev.numbers?
      noun = fold!(prev, noun, ptag, flip: prev.ordinal?)
      return noun unless prev = noun.prev?
    end

    if prev.pro_dems? || prev.pro_na2?
      flip = should_flip_pro_dems?(prev)
      noun = fold!(prev, noun, ptag, flip: flip)
      return noun unless prev = noun.prev?
    end

    return noun unless prev.all_prons?
    fold!(prev, noun, ptag, flip: ptag.posit?)
  end

  def fold_noun_noun_left!(noun : MtNode, prev : MtNode)
    case noun
    when .honor?          then return fold_honor_noun_left!(noun, prev)
    when .proper_nouns?   then return fold_name_noun_left!(noun, prev)
    when .locat?, .posit? then return fold!(prev, noun, MapTag::Posit, flip: true)
    when .nattr?
      return fold!(prev, noun, noun.tag, flip: true) if prev.nattr?
    end

    case prev
    when .posit?, .nattr?
      flip = true
    else
      flip = should_flip_noun?(prev.prev?, noun.succ?)
    end

    fold!(prev, noun, MapTag::Nform, flip: flip)
    # next_is_verb = noun.succ? { |x| x.verbal? || x.preposes? }
  end

  def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verbal?
    return false if prev.vtwo?
    succ.verbal?
  end

  def should_flip_pro_dems?(prodem)
    case prodem
    when .pro_zhe?, .pro_na1?, .pro_na2?
      true
    else
      false
    end
  end

  def fold_honor_noun_left!(noun, prev)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      ptag = MapTag::Nform
    else
      ptag = MapTag::CapHuman
    end

    fold!(prev, noun, ptag, flip: false)
  end

  def fold_name_noun_left!(name, prev)
    case prev
    when .cap_affil?
      return fold!(prev, name, name.tag, flip: true)
    when .cap_human?
      return fold!(prev, name, name.tag, flip: false) if name.cap_human?
    end

    fold!(prev, name, MapTag::Nform, flip: false)
  end
end
