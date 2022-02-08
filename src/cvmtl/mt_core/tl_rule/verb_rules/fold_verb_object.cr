module CV::TlRule
  def fold_verb_object!(verb : MtNode, succ : MtNode?)
    return verb if !succ || verb.verb_object? || verb.vintr?

    if succ.ude1?
      return verb if verb.prev? { |x| x.object? || x.prep_phrase? }
      return verb unless (object = scan_noun!(succ.succ?)) && object.object?
      node = fold!(verb, succ.set!(""), PosTag::DefnPhrase, dic: 6)
      return fold!(node, object, object.tag, dic: 8, flip: true)
    end

    return verb unless (noun = scan_noun!(succ)) && noun.object?

    if noun.place? && verb.ends_with?('在')
      return fold!(verb, noun, PosTag::VerbObject, dic: 4)
    end

    if (ude1 = noun.succ?) && ude1.ude1? && (right = ude1.succ?)
      if (right = scan_noun!(right)) && should_apply_ude1_after_verb?(verb, right)
        noun = fold_ude1_left!(ude1: ude1, left: noun, right: right)
      end
    end

    node = fold!(verb, noun, PosTag::VerbObject, dic: 9)
    return node unless (succ = node.succ?) && succ.junction?
    fold_verb_junction!(junc: succ, verb: node) || node
  end

  def should_apply_ude1_after_verb?(verb : MtNode, right : MtNode?, prev = verb.prev?)
    # puts [verb, right, verb.prev?, "verb-object"]

    return false if verb.body?.try(&.pre_bei?)

    while prev && prev.adverb?
      prev = prev.prev?
    end

    return false unless prev && right
    return false if {"时候", "时", "打算", "方法"}.includes?(right.key)

    case prev.tag
    when .comma? then return true
    when .v_shi? then return false
    when .v_you? then return false
    when .verbs? then return is_linking_verb?(prev, verb)
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
