module MT::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not join junctions
  # 3 => scan_noun after ude1
  #   can return non nominal node

  # ameba:disable Metrics/CyclomaticComplexity
  def scan_noun!(node : MtNode?, mode : Int32 = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    raise "dead code!"
    # puts [node, prodem, nquant, "scan_noun"]
    # return fold_prodem_nominal!(prodem, nquant) unless node

    # if node.ptcl_dep?
    #   return node unless left = fold_prodem_nominal!(prodem, nquant)
    #   return fold_ude1!(ude1: node, prev: left)
    # end

    # while node
    #   case node
    #   when .pro_pers?
    #     if prodem || nquant
    #       node = nil
    #     else
    #       node = fold_pro_per!(node, node.succ?)
    #     end

    #     break
    #   when .dem_prons?
    #     if prodem || nquant
    #       # TODO: call scan_noun here then fold
    #       node = nil
    #     else
    #       prodem = node
    #       node = node.succ?
    #     end
    #   when .pro_ints?
    #     node = fold_pro_ints!(node, node.succ?)
    #     node = nil if node.int_prons?
    #   when .numeral?
    #     if nquant
    #       node = nil
    #     else
    #       node = fold_number!(node)
    #       break unless node.numeral?
    #       nquant, node = node, node.succ?
    #       next
    #     end
    #   when .v_you?
    #     break unless (succ = node.succ?) && succ.common_nouns?
    #     succ = fold_nouns!(succ)
    #     node = fold!(node, succ, MapTag::Aform)
    #     node = fold_head_ude1_noun!(node)
    #   when .advb_words?
    #     node = fold_adverbs!(node)

    #     case node.tag
    #     when .verbal_words??
    #       node = fold_verb_as_noun!(node, mode: mode)
    #     when .adjt_words?
    #       node = fold_adjt_as_noun!(node)
    #     when .advb_words?
    #       break
    #     else
    #       # puts [node, node.tag]
    #     end
    #   when .preposes?
    #     # break unless prodem || nquant
    #     node = fold_preposes!(node, mode: 3)
    #     # puts [node, node.body?]

    #     if (ude1 = node.succ?) && ude1.ptcl_dep?
    #       node = fold_ude1!(ude1: ude1, prev: node)
    #     elsif node.verbal_words??
    #       node = fold_verb_as_noun!(node, mode: mode)
    #     elsif node.adjt_words?
    #       node = fold_adjt_as_noun!(node)
    #     end

    #     break
    #   when .vobj?
    #     break unless succ = node.succ?

    #     case succ
    #     when .noun_words?
    #       succ = fold_nouns!(succ, mode: 1)
    #       node = fold!(node, succ, MapTag::Nform, flip: true)
    #     when .ptcl_dep?
    #       node = fold_ude1!(ude1: succ, prev: node)
    #     end
    #   when .modal_verbs?
    #     node = fold_vmodal!(node)

    #     if node.preposes?
    #       node = fold_preposes!(node, mode: 1)
    #     elsif node.verbal_words??
    #       node = fold_verb_as_noun!(node, mode: mode)
    #     elsif node.adjt_words?
    #       node = fold_adjt_as_noun!(node)
    #     end
    #   when .v_shi?
    #     break
    #   when .verbal_words??
    #     node = fold_verb_as_noun!(node, mode: mode)
    #   when .onomat?
    #     node = fold_adjt_as_noun!(node)
    #   when .amod_words?
    #     node = fold_amod_words?(node)
    #     node = fold_adjt_as_noun!(node)
    #   when .adjt_words?
    #     node = fold_adjt_as_noun!(node)
    #   when .noun_words?
    #     case node = fold_nouns!(node)
    #     when .nattr?
    #       node = fold_head_ude1_noun!(node)
    #     when .cap_affil?, .posit?
    #       node = fold_head_ude1_noun!(node) if prodem || nquant
    #     when .noun_words?
    #       break
    #     else
    #       node = scan_noun!(node) || node unless node.noun_words?
    #     end
    #   when .ptcl_dev?
    #     if node.prev? { |x| x.prep_zai? || x.verbal_words?? } || node.succ?(&.position?)
    #       node.set!("đất", MapTag.make(:noun))
    #     end
    #   end

    #   break
    # end

    # return fold_prodem_nominal!(prodem, nquant) unless node && node.object?

    # if nquant
    #   nquant = clean_nquant(nquant, prodem)
    #   node = fold!(nquant, node, MapTag::Nform)
    # end

    # node = fold_prodem_nominal!(prodem, node) if prodem
    # # node = fold_proper_nominal!(proper, node) if proper

    # return node if mode != 0 || !(succ = node.succ?) || succ.boundary?

    # node = fold_noun_after!(node, succ)
    # return node if node.prev?(&.preposes?) && !node.property?

    # return node unless (verb = node.succ?) && verb.maybe_verb?
    # verb = scan_verbs!(verb)

    # return node if verb.verb_no_obj?
    # return node unless (ude1 = verb.succ?) && ude1.ptcl_dep?
    # return node unless (tail = scan_noun!(ude1.succ?)) && tail.object?

    # node = fold!(node, ude1.set!(""), MapTag::DcPhrase)
    # fold!(node, tail, MapTag::Nform, flip: true)
  end

  def clean_nquant(nquant : MtNode, prodem : MtNode?)
    return nquant unless prodem || nquant.is_a?(BaseList) || nquant.key.size > 1

    nquant.each do |node|
      case node.key
      when "些"             then node.val = "những"
      when .includes?('个') then node.val = node.val.sub("cái", "").strip
      end
    end

    nquant
  end

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (ude1 = head.succ?) && ude1.ptcl_dep?
    ude1.val = "" unless head.common_nouns? || head.proper_nouns?

    return head unless tail = scan_noun!(ude1.succ?)
    fold!(head, tail, MapTag::Nform, flip: true)
  end

  def fold_adjt_as_noun!(node : MtNode)
    return node if node.noun_words? || !(succ = node.succ?)

    noun, ude1 = succ.ptcl_dep? ? {succ.succ?, succ} : {succ, nil}
    fold_adjt_noun!(node, noun, ude1)
  end

  def fold_verb_as_noun!(node : MtNode, mode = 0)
    node = fold_verbs!(node)
    return node if node.noun_words? || mode == 3 || !(succ = node.succ?)

    unless succ.ptcl_dep? || node.verb_no_obj?
      return node unless succ = scan_noun!(succ, mode: 0)
      node = fold!(node, succ, MapTag::Vobj)
    end

    fold_verb_ude1!(node)
  end

  def fold_verb_ude1!(node : MtNode, succ = node.succ?)
    return node unless succ && succ.ptcl_dep?
    return node unless (noun = scan_noun!(succ.succ?, mode: 1)) && noun.object?

    node = fold!(node, succ.set!(""), MapTag::DcPhrase)

    tag = noun.proper_nouns? || noun.cap_human? ? noun.tag : MapTag::Nform
    fold!(node, noun, tag, flip: true)
  end
end