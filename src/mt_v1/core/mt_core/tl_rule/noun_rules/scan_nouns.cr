module M1::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not join junctions
  # 3 => scan_noun after ude1
  #   can return non nominal node

  # ameba:disable Metrics/CyclomaticComplexity
  def scan_noun!(node : MtNode?, mode : Int32 = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    # puts [node, prodem, nquant, "scan_noun"]
    return fold_prodem_nominal!(prodem, nquant) unless node

    if node.ude1?
      return node unless left = fold_prodem_nominal!(prodem, nquant)
      return fold_ude1!(ude1: node, prev: left)
    end

    while node
      node = heal_mixed!(node) if node.is_a?(MtDefn) && node.polysemy?

      case node
      when .pro_per?
        if prodem || nquant
          node = nil
        else
          node = fold_pro_per!(node, node.succ?)
        end

        break
      when .pro_dems?
        if prodem || nquant
          # TODO: call scan_noun here then fold
          node = nil
        else
          prodem, nquant, node = split_prodem!(node, node.succ?)
          next
        end
      when .pro_ints?
        node = fold_pro_ints!(node, node.succ?)
        node = nil if node.pro_int?
      when .numeral?
        if nquant
          node = nil
        else
          node = fold_number!(node)
          break unless node.numeral?
          nquant, node = node, node.succ?
          next
        end
      when .v_you?
        break unless (succ = node.succ?) && succ.noun?
        succ = fold_nouns!(succ)
        node = fold!(node, succ, PosTag::Aform, dic: 4)
        node = fold_head_ude1_noun!(node)
      when .adverbial?
        node = fold_adverbs!(node)

        case node.tag
        when .verbal?
          node = fold_verb_as_noun!(node, mode: mode)
        when .adjective?
          node = fold_adjt_as_noun!(node)
        when .adverb?
          break
        else
          # puts [node, node.tag]
        end
      when .preposes?
        # break unless prodem || nquant
        node = fold_preposes!(node, mode: 3)
        # puts [node, node.body?]

        if (ude1 = node.succ?) && ude1.ude1?
          node = fold_ude1!(ude1: ude1, prev: node)
        elsif node.verbal?
          node = fold_verb_as_noun!(node, mode: mode)
        elsif node.adjective?
          node = fold_adjt_as_noun!(node)
        end

        break
      when .verb_object?
        break unless succ = node.succ?

        case succ
        when .nominal?
          succ = fold_nouns!(succ, mode: 1)
          node = fold!(node, succ, PosTag::NounPhrase, dic: 5, flip: true)
        when .ude1?
          node = fold_ude1!(ude1: succ, prev: node)
        end
      when .vmodals?
        node = fold_vmodals!(node)

        if node.preposes?
          node = fold_preposes!(node, mode: 1)
        elsif node.verbal?
          node = fold_verb_as_noun!(node, mode: mode)
        elsif node.adjective?
          node = fold_adjt_as_noun!(node)
        end
      when .v_shi?
        break
      when .verbal?
        node = fold_verb_as_noun!(node, mode: mode)
      when .onomat?
        node = fold_adjt_as_noun!(node)
      when .modi?
        node = fold_modifier!(node)
        node = fold_adjt_as_noun!(node)
      when .adjective?
        node = fold_adjt_as_noun!(node)
      when .nominal?
        case node = fold_nouns!(node)
        when .nattr?
          node = fold_head_ude1_noun!(node)
        when .naffil?, .posit?
          node = fold_head_ude1_noun!(node) if prodem || nquant
        when .nominal?
          break
        else
          node = scan_noun!(node) || node unless node.nominal?
        end
      when .ude2?
        if node.prev? { |x| x.pre_zai? || x.verbal? } || node.succ?(&.spaces?)
          node.set!("đất", PosTag::Noun)
        end
      end

      break
    end

    return fold_prodem_nominal!(prodem, nquant) unless node && node.object?

    if nquant
      nquant = clean_nquant(nquant, prodem)
      node = fold!(nquant, node, PosTag::Nform, dic: 4)
    end

    node = fold_prodem_nominal!(prodem, node) if prodem
    # node = fold_proper_nominal!(proper, node) if proper

    return node if mode != 0 || !(succ = node.succ?) || succ.ends?

    node = fold_noun_after!(node, succ)
    return node if node.prev?(&.preposes?) && !node.property?

    return node unless (verb = node.succ?) && verb.maybe_verb?
    verb = scan_verbs!(verb)

    return node if verb.verb_no_obj?
    return node unless (ude1 = verb.succ?) && ude1.ude1?
    return node unless (tail = scan_noun!(ude1.succ?)) && tail.object?

    node = fold!(node, ude1.set!(""), PosTag::DefnPhrase, dic: 4)
    fold!(node, tail, PosTag::NounPhrase, dic: 9, flip: true)
  end

  def clean_nquant(nquant : MtNode, prodem : MtNode?)
    return nquant unless prodem || nquant.is_a?(MtList) || nquant.key.size > 1

    nquant.each do |node|
      case node.key
      when "些"             then node.val = "những"
      when .includes?('个') then node.val = node.val.sub("cái", "").strip
      end
    end

    nquant
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (ude1 = head.succ?) && ude1.ude1?
    ude1.val = "" unless head.noun? || head.names?

    return head unless tail = scan_noun!(ude1.succ?)
    fold!(head, tail, PosTag::NounPhrase, dic: 8, flip: true)
  end

  def fold_adjt_as_noun!(node : MtNode)
    return node if node.nominal? || !(succ = node.succ?)

    noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
    fold_adjt_noun!(node, noun, ude1)
  end

  def fold_verb_as_noun!(node : MtNode, mode = 0)
    node = fold_verbs!(node)
    return node if node.nominal? || mode == 3 || !(succ = node.succ?)

    unless succ.ude1? || node.verb_object? || node.vintr?
      return node unless succ = scan_noun!(succ, mode: 0)
      node = fold!(node, succ, PosTag::VerbObject, dic: 6)
    end

    fold_verb_ude1!(node)
  end

  def fold_verb_ude1!(node : MtNode, succ = node.succ?)
    return node unless succ && succ.ude1?
    return node unless (noun = scan_noun!(succ.succ?, mode: 1)) && noun.object?

    node = fold!(node, succ.set!(""), PosTag::DefnPhrase, dic: 7)

    tag = noun.names? || noun.human? ? noun.tag : PosTag::NounPhrase
    fold!(node, noun, tag, dic: 6, flip: true)
  end
end
