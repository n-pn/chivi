module CV::TlRule
  # modes:
  # 1 => do not include spaces after nouns
  # 2 => do not join junctions
  # 3 => scan_noun after ude1
  #   can return non nominal node

  def scan_noun!(node : Nil, mode = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    fold_prodem_nominal!(prodem, nquant)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def scan_noun!(node : MtNode, mode : Int32 = 0,
                 prodem : MtNode? = nil, nquant : MtNode? = nil)
    # puts [node, prodem, nquant, "scan_noun"]

    node = fold_once!(node)

    case node.tag
    when .puncts?
      return fold_prodem_nominal!(prodem, nquant)
    when .pronouns?
      return fold_prodem_nominal!(prodem, nquant) if prodem || nquant
    when .nominal?, .numeral?
      # do nothing
    when .v_shi?
      node = fold_v_shi!(node)
    when .verb_object?
      node = fold_verb_object_as_noun!(node)
    when .verbal?
      node = fold_verb_as_noun!(node)
    when .adjective?
      node = fold_adjt_as_noun!(node)
    else
      return node unless (ude1 = node.succ?) && ude1.ude1?
      return node unless tail = scan_noun!(ude1.succ?)
      node = fold_ude1_left!(ude1, left: node, right: tail)
    end

    return fold_prodem_nominal!(prodem, nquant) unless node.object?
    node = fold_nquant_nominal!(nquant, node) if nquant
    node = fold_prodem_nominal!(prodem, node) if prodem

    return node unless mode == 0 && (succ = node.succ?)
    scan_noun_after!(node, succ)
  end

  def fold_verb_object_as_noun!(head : MtNode)
    return head.flag!(:resolved) unless succ = head.succ?

    case succ
    when .nominal?
      succ = fold_nouns!(succ, mode: 1)
      fold!(head, succ, PosTag::NounPhrase, dic: 5, flip: true)
    when .ude1?
      fold_ude1!(ude1: succ, prev: head)
    else
      head
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

  def fold_head_ude1_noun!(head : MtNode)
    return head unless (ude1 = head.succ?) && ude1.ude1?
    ude1.val = "" unless head.noun? || head.names?

    return head unless tail = scan_noun!(ude1.succ?)
    fold!(head, tail, PosTag::NounPhrase, dic: 8, flip: true)
  end

  def fold_adjt_as_noun!(node : MtNode)
    return node.flag!(:resolved) unless succ = node.succ?
    noun, ude1 = succ.ude1? ? {succ.succ?, succ} : {succ, nil}
    fold_adjt_noun!(node, noun, ude1)
  end

  def fold_verb_as_noun!(node : MtNode, mode = 0)
    # puts [node, node.succ?]
    return node.flag!(:resolved) unless succ = node.succ?

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

  def scan_noun_after!(node : MtNode, succ = node.succ) : MtNode
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
end
