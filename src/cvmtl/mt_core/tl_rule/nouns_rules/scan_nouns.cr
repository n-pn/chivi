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
      when .uniques?
        node = heal_uniques!(node)
        break
      when .popens?
        node = fold_quoted!(node)
        node = fold_noun!(node) if node.nouns?
        break
      when .pro_per?
        node = proper || prodem || nquant ? nil : fold_pro_per!(node, node.succ?)
        break
      when .pro_dems?
        break if prodem || nquant
        prodem, nquant, node = split_prodem!(node, node.succ?)
      when .numeric?
        break if nquant
        node = fuse_number!(node)
        break unless node.numeric?
        nquant, node = node, node.succ?
      when .adverbs?
        node = fold_adverbs!(node)
        node = fold_head_ude1_noun!(node) if node.adjts? || node.verbs?
        break
      when .adjts?
        node = node.ajno? ? fold_ajno!(node) : fold_adjts!(node)

        unless node.nouns? || !(succ = node.succ?)
          noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
          node = fold_adjt_noun!(node, noun, ude1)
        end

        break
      when .vmodal?
        if vmodal_is_noun?(node)
          node.tag = PosTag::Noun
        else
          node = heal_vmodal!(node)
          node = fold_head_ude1_noun!(node) if node.verbs?
        end

        break
      when .verbs?
        node = node.veno? ? fold_veno!(node) : fold_verbs!(node)
        node = fold_head_ude1_noun!(node) if node.verbs?
        break
      when .nouns?
        node = fold_noun!(node, mode: 1)
        node = scan_noun!(node) || node unless node.nouns?
        break
      else
        break
      end
    end

    unless node && node.center_noun?
      return fold_prodem_nounish!(prodem, nquant)
    end

    # puts [node, prodem, nquant]

    if nquant
      # puts [nquant, nquant.key, nquant.val]
      nquant.each do |node|
        case node.key
        when "些" then node.val = "những"
        when "个" then node.val = ""
        end
      end

      node = fold!(nquant, node, node.tag, dic: 4)
    end

    node = fold_prodem_nounish!(prodem, node) if prodem
    node = fold_proper_nounish!(proper, node) if proper
    mode != 1 ? fold_noun_after!(node, node.succ?) : node
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
end
