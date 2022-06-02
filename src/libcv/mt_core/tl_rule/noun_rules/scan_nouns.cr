module CV::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not join junctions
  # 3 => scan_noun after ude1
  #   can return non nominal node

  def scan_noun!(node : Nil, mode = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    prodem && nquant ? fold_prodem_nominal!(prodem, nquant) : nil
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def scan_noun!(node : MtNode, mode : Int32 = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    node = fold_once!(node)
    # puts [node, prodem, nquant, "scan_noun"]

    case node.tag
    when .nominal?, .numeral?, .verb_object?
      node = fold_nquant_nominal!(nquant, node) if nquant
      node = fold_prodem_nominal!(prodem, node) if prodem

      return node unless succ = node.succ?
      scan_noun_after!(node, succ)
    when .pronouns?
      return node unless prodem || nquant
      prodem && nquant ? fold_prodem_nominal!(prodem, nquant) : prodem || nquant
    else
      prodem && nquant ? fold_prodem_nominal!(prodem, nquant) : prodem || nquant
    end
  end

  def fold_nquant_nominal!(nquant : MtNode, nominal : MtNode)
    case nquant.key
    when "些"
      nquant.val = "những"
    when "个"
      nquant.val = "" if nquant.prev?(&.pro_dems?)
    else
      clean_nquant!(nquant) if nquant.flag.has_qt_ge4?
    end

    if nominal.key == "个人"
      nominal.val = "người"
    end

    fold!(nquant, nominal, PosTag::NounPhrase, dic: 3).flag!(:checked)
  end

  def clean_nquant!(nquant : MtNode) : Nil
    nquant.each do |node|
      if body = node.body?
        clean_nquant!(body)
        return
      elsif node.key == "个"
        node.val = ""
        return
      end
    end
  end

  # def fold_head_ude1_noun!(head : MtNode)
  #   return head unless (ude1 = head.succ?) && ude1.ude1?
  #   ude1.val = "" unless head.noun? || head.names?

  #   return head unless tail = scan_noun!(ude1.succ?)
  #   fold!(head, tail, PosTag::NounPhrase, dic: 8, flip: true)
  # end

  # def fold_adjt_as_noun!(node : MtNode)
  #   return node.flag!(:resolved) unless succ = node.succ?
  #   noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
  #   fold_adjt_noun!(node, noun, ude1)
  # end

  # def fold_verb_as_noun!(node : MtNode, mode = 0)
  #   # puts [node, node.succ?]
  #   return node.flag!(:resolved) unless succ = node.succ?

  #   unless succ.ude1? || node.v0_obj?
  #     return node unless succ = scan_noun!(succ, mode: 0)
  #     node = fold!(node, succ, PosTag::VerbObject, dic: 6)
  #   end

  #   fold_verb_ude1!(node)
  # end

  # def fold_verb_ude1!(node : MtNode, succ = node.succ?)
  #   return node unless succ && succ.ude1?
  #   return node unless (noun = scan_noun!(succ.succ?, mode: 1)) && noun.object?

  #   node = fold!(node, succ.set!(""), PosTag::DefnPhrase, dic: 7)

  #   tag = noun.names? || noun.human? ? noun.tag : PosTag::NounPhrase
  #   fold!(node, noun, tag, dic: 6, flip: true)
  # end

  def scan_noun_after!(node : MtNode, succ = node.succ) : MtNode
    node = fold_noun_after!(node, succ)
    return node if node.prev?(&.preposes?) && !node.property?

    return node unless (verb = node.succ?) && verb.maybe_verb?
    verb = scan_verbs!(verb)

    return node if verb.v0_obj?
    return node unless (ude1 = verb.succ?) && ude1.ude1?
    return node unless (tail = scan_noun!(ude1.succ?)) && tail.object?

    node = fold!(node, ude1.set!(""), PosTag::DefnPhrase, dic: 4)
    fold!(node, tail, PosTag::NounPhrase, dic: 9, flip: true)
  end
end
