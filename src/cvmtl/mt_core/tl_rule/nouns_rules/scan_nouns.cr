module CV::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not combine verb with object
  def scan_noun!(node : MtNode?, mode : Int32 = 0,
                 proper : MtNode? = nil, proint : MtNode? = nil,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    while node && !node.ends?
      # puts ["scan_noun", node, mode]

      case node
      when .pro_dems?
        if prodem || nquant
          node = nil
        else
          prodem, nquant, node = split_prodem!(node, node.succ?)
          next
        end
      when .numeric?
        if nquant
          node = nil
        else
          node = fuse_number!(node)
          break unless node.numeric?
          nquant, node = node, node.succ?
        end
      when .uniques?
        node = heal_uniques!(node)
      when .popens?
        node = fold_quoted!(node)
        node = fold_noun!(node) if node.nouns?
      when .pro_per?
        node = proper || prodem || nquant ? nil : fold_pro_per!(node, node.succ?)
      when .adverbs?
        node = fold_adverbs!(node)
        case node.tag
        when .verbs?
          node = fold_verb_as_noun!(node)
        when .adjts?
          node = fold_adjt_as_noun!(node)
        when .adverb?
          node = nil
        else
          puts [node, node.tag]
        end
      when .adjts?
        node = node.ajno? ? fold_ajno!(node) : fold_adjts!(node)
        node = fold_adjt_as_noun!(node)
      when .verb_object?
        break unless succ = node.succ?

        case succ
        when .nouns?
          succ = fold_noun!(succ, mode: 1)
          node = fold!(node, succ, PosTag::NounPhrase, dic: 5, flip: true)
        when .ude1?
          ude1 = fold_ude1_left!(node, succ, succ.succ?)
          node = ude1 unless ude1.ude1?
        end
      when .verbs?
        node = fold_verb_as_noun!(node)
      when .nouns?
        node = fold_noun!(node, mode: 1)
        node = scan_noun!(node) || node unless node.nouns?
      end

      break
    end

    unless node && node.center_noun?
      return fold_prodem_nounish!(prodem, nquant)
    end

    # puts [node, prodem, nquant]

    if nquant
      # puts [nquant, nquant.key, nquant.val]

      nquant = clean_nquant(nquant, prodem)
      node = fold!(nquant, node, node.tag, dic: 4)
    end

    node = fold_prodem_nounish!(prodem, node) if prodem
    node = fold_proper_nounish!(proper, node) if proper

    return node unless mode != 1 && (succ = node.succ?)

    fold_uzhi!(uzhi: succ, prev: node) if succ.uzhi?
    fold_noun_space!(noun: node, space: node.succ?)
  end

  def clean_nquant(nquant : MtNode, prodem : MtNode?)
    return nquant.set!("những") if prodem && nquant.key == "些"
    return nquant.set!("") if prodem && nquant.key == "个"

    if body = nquant.body?
      while body
        if body.key.includes?("个")
          body.val = body.val.sub(/\s*cái*/, "")
          break
        else
          body = body.succ?
        end
      end
    end

    nquant
  end

  def fold_noun_after!(noun : MtNode, succ : MtNode? = noun.succ?)
    return noun unless succ

    case succ
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: noun)
    when .space?
      fold_noun_space!(noun: noun, space: succ)
    else
      noun
    end
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (succ = head.succ?) && succ.ude1?
    succ.val = "" unless head.noun? || head.names?

    return head unless tail = scan_noun!(succ.succ?)
    fold!(head, tail, PosTag::NounPhrase, dic: 4, flip: true)
  end

  def fold_adjt_as_noun!(node : MtNode)
    return node if node.nouns? || !(succ = node.succ?)

    noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
    fold_adjt_noun!(node, noun, ude1)
  end

  def fold_verb_as_noun!(node : MtNode, prev : MtNode? = nil)
    return node if node.v_shi?

    case node
    when .vmodal?
      if vmodal_is_noun?(node)
        node.tag = PosTag::Noun
        return fold_noun!(node, mode: 1)
      end

      node = heal_vmodal!(node)
    when .veno?
      node = fold_veno!(node)
    when .verb_object?
      # do nothing
    else
      node = fold_verbs!(node)
    end

    if node.nouns?
      return prev ? fold!(prev, node, PosTag::NounPhrase, dic: 9, flip: true) : node
    end

    unless succ = node.succ?
      return prev || node
    end

    unless succ.ude1? || node.verb_object? || node.vintr?
      return prev || node unless succ = scan_noun!(succ, mode: 0)
      node = fold!(node, succ, PosTag::VerbObject, dic: 6)
    end

    fold_verb_ude1!(node)
  end

  def fold_verb_ude1!(node : MtNode, succ = node.succ?)
    return node unless succ && succ.ude1?
    node = fold!(node, succ.set!(""), PosTag::DefnPhrase, dic: 7)

    return node unless noun = scan_noun!(node.succ, mode: 1)
    fold!(node, succ, PosTag::NounPhrase, dic: 6, flip: true)
  end
end
