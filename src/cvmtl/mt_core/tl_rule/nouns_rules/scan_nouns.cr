module CV::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => ??
  # 3 => scan_noun after ude1
  #   can return non nounish node
  def scan_noun!(node : MtNode?, mode : Int32 = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    # puts [node, prodem, nquant, "scan_noun"]

    while node
      case node
      when .popens?
        node = fold_nested!(node)

        if node.nouns?
          node = fold_noun!(node)
        else
          node = node.popens? ? nil : node
        end
      when .pro_per?
        node = nil if prodem || nquant
      when .pro_dems?
        if prodem || nquant
          # TODO: call scan_noun here then fold
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
          next
        end
      when .uniques?
        node = heal_uniques!(node)
      when .adverbs?
        node = fold_adverbs!(node)

        case node.tag
        when .verbs?
          node = fold_verb_as_noun!(node, mode: mode)
        when .adjts?
          node = fold_adjt_as_noun!(node)
        when .adverb?
          break
        else
          # puts [node, node.tag]
        end
      when .preposes?
        node = fold_preposes!(node, mode: 1) if prodem || nquant
        # puts [node, node.succ?]
      when .verb_object?
        break unless succ = node.succ?

        case succ
        when .nouns?
          succ = fold_noun!(succ, mode: 1)
          node = fold!(node, succ, PosTag::NounPhrase, dic: 5, flip: true)
        when .ude1?
          node = fold_ude1!(ude1: succ, prev: node)
        end
      when .vmodals?
        node = heal_vmodal!(node)

        if node.preposes?
          node = fold_preposes!(node, mode: 1)
        elsif node.verbs?
          node = fold_verb_as_noun!(node, mode: mode)
        elsif node.adjts?
          node = fold_adjt_as_noun!(node)
        end
      when .verbs?
        node = fold_verb_as_noun!(node, mode: mode)
      when .adjts?
        node = node.ajno? ? fold_ajno!(node) : fold_adjts!(node)
        node = fold_adjt_as_noun!(node)
      when .nouns?
        node = fold_noun!(node, mode: 1)
        node = scan_noun!(node) || node unless node.nouns?
      end

      break
    end

    unless node && node.subject?
      return fold_prodem_nounish!(prodem, nquant)
    end

    if nquant
      nquant = clean_nquant(nquant, prodem)
      node = fold!(nquant, node, node.tag, dic: 4)
    end

    node = fold_prodem_nounish!(prodem, node) if prodem
    # node = fold_proper_nounish!(proper, node) if proper

    return node unless mode == 0 && (succ = node.succ?)

    node = fold_uzhi!(uzhi: succ, prev: node) if succ.uzhi?
    fold_noun_space!(noun: node)
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

  def fold_verb_as_noun!(node : MtNode, prev : MtNode? = nil, mode = 0)
    # puts [node, node.succ?]

    case node
    when .v_shi? then return node
    when .veno?
      node = fold_veno!(node)
    else
      node = fold_verbs!(node)
    end

    if node.nouns?
      return node unless prev
      return fold!(prev, node, PosTag::NounPhrase, dic: 9, flip: true)
    elsif mode == 3 || !(succ = node.succ?)
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

    return node unless noun = scan_noun!(node.succ?, mode: 1)
    fold!(node, noun, PosTag::NounPhrase, dic: 6, flip: true)
  end
end
