module MtlV2::TlRule
  def scan_noun!(node : Nil, prodem : BaseNode? = nil, nquant : BaseNode? = nil)
    fold_prodem_nominal!(prodem, nquant)
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  def scan_noun!(node : BaseNode, prodem : BaseNode? = nil, nquant : BaseNode? = nil)
    if node.pd_dep?
      return node unless left = fold_prodem_nominal!(prodem, nquant)
      # puts [left, node]
      return fold_ude1!(ude1: node, left: left)
    end

    node = fold_once!(node)
    # puts [node, prodem, nquant, "scan_noun"]

    case node.tag
    when .nominal?, .numeral?, .verb_object?
      node = fold_nquant_nominal!(nquant, node) if nquant
      prodem ? fold_prodem_nominal!(prodem, node) : fold_noun_other!(node)
    when .pronouns?
      fold_prodem_nominal!(prodem, nquant) || fold_noun_other!(node)
    else
      fold_prodem_nominal!(prodem, nquant)
    end
  end

  def fold_nquant_nominal!(nquant : BaseNode, nominal : BaseNode)
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

  def clean_nquant!(nquant : BaseNode) : Nil
    nquant.each do |node|
      if body = node.body?
        clean_nquant!(body)
        next
      elsif node.key == "个"
        node.val = ""
        next
      end
    end
  end

  # def scan_noun_after!(node : BaseNode, succ = node.succ?) : BaseNode
  #   return noun if !succ || succ.ends?

  #   node = fold_noun_after!(node, succ)
  #   return node if node.prev?(&.preposes?) && !node.property?

  #   return node unless (verb = node.succ?) && verb.maybe_verb?
  #   verb = scan_verbs!(verb)

  #   return node if verb.v0_obj?
  #   return node unless (ude1 = verb.succ?) && ude1.pd_dep?
  #   return node unless (tail = scan_noun!(ude1.succ?)) && tail.object?

  #   node = fold!(node, ude1.set!(""), PosTag::DefnPhrase, dic: 4)
  #   fold!(node, tail, PosTag::NounPhrase, dic: 9, flip: true)
  # end
end
