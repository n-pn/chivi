module M1::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_object!(verb : MtNode, succ : MtNode?)
    # puts [verb, succ].colorize.red

    return verb if !succ || succ.ends? || verb.verb_object? || verb.vintr?

    if succ.ude1?
      return verb if verb.prev? { |x| x.object? || x.prep_clause? }
      return verb unless (object = scan_noun!(succ.succ?)) && object.object?

      return verb if !(verb_2 = object.succ?) || verb_2.ends?
      verb_2 = fold_once!(verb_2)
      return verb if !verb_2.verb_no_obj? && verb.prev?(&.object?)

      node = fold!(verb, succ.set!(""), PosTag::DefnPhrase, dic: 6)
      return fold!(node, object, object.tag, dic: 8, flip: true)
    end

    return verb unless (noun = scan_noun!(succ)) && noun.object?

    if noun.posit? && verb.ends_with?('在')
      return fold!(verb, noun, PosTag::VerbObject, dic: 4)
    end

    if (ude1 = noun.succ?) && ude1.ude1? && (right = ude1.succ?)
      if (right = scan_noun!(right)) && should_apply_ude1_after_verb?(verb, right)
        noun = fold_ude1_left!(ude1: ude1, left: noun, right: right)
      end
    end

    verb_object = fold!(verb, noun, PosTag::VerbObject, dic: 8)
    return verb_object unless succ = verb_object.succ?

    if succ.suf_noun? && succ.key == "时"
      fold!(verb_object, succ.set!("khi"), tag: PosTag::Ntime, dic: 5, flip: true)
    elsif succ.junction?
      fold_verb_junction!(junc: succ, verb: verb_object) || verb_object
    else
      verb_object
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def should_apply_ude1_after_verb?(verb : MtNode, right : MtNode?, prev = verb.prev?)
    return false if verb.is_a?(MtList) && verb.list.any?(&.pre_bei?)
    return false if verb.v2_obj?

    while prev && prev.adverb?
      prev = prev.prev?
    end

    return false unless prev && right

    # in case after ude1 is adverb
    if {"时候", "时", "打算", "方法"}.includes?(right.key)
      return false
    elsif right.succ? { |x| x.ends? || x.ule? }
      return true
    end

    case prev.tag
    when .comma?   then return true
    when .v_shi?   then return false
    when .v_you?   then return false
    when .verbal?  then return is_linking_verb?(prev, verb)
    when .nquants? then return false
    when .subject?
      return true unless head = prev.prev?
      return false if head.v_shi?
      return true if head.none? || head.unkn? || head.pstops?
    when .none?, .pstops?, .unkn?
      return !find_verb_after(right)
    end

    find_verb_after(right).try { |x| is_linking_verb?(verb, x) } || true
  end
end
