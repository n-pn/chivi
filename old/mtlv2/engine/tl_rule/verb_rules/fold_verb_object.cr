module MT::TlRule
  # -ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_object!(verb : MtNode, succ = verb.succ)
    noun = fold_once!(succ) # unless noun.flag.checked

    # puts [verb, succ, "fold_verb_object"]
    return verb unless noun.object?

    # if noun.position? && verb.flag.has_pre_zai?

    #   return fold!(verb, noun, PosTag::VerbObject, dic: 4)
    # end

    # if (ude1 = noun.succ?) && ude1.pd_dep? && (right = ude1.succ?)
    #   if (right = scan_noun!(right)) && should_apply_ude1_after_verb?(verb, right)
    #     noun = fold_ude1!(ude1: ude1, left: noun, right: right)
    #   end
    # end

    fix_auxil_in_verb_phrase!(verb)
    fold!(verb, noun, PosTag::VerbObject, dic: 3)
  end

  def fix_auxil_in_verb_phrase!(verb : MtNode)
    verb.each do |node|
      if body = node.body?
        fix_auxil_in_verb_phrase!(body)
      else
        case node.key
        when .includes?('在')
          node.val = node.val.sub("tại", "ở")
        when .includes?('了')
          node.val = node.val.sub(/\s?rồi/, "")
        when .includes?('着')
          node.val = node.val.sub(/\s?lấy/, "")
        end
      end
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def should_apply_ude1_after_verb?(verb : MtNode, right : MtNode?, prev = verb.prev?)
    return false if verb.body?(&.pre_bei?) || need_2_objects?(verb)

    while prev && prev.adverb?
      prev = prev.prev?
    end

    return false unless prev && right

    # in case after ude1 is adverb
    if {"打算", "方法"}.includes?(right.key)
      return false
    elsif right.succ? { |x| x.ends? || x.ule? }
      return true
    end

    case prev.tag
    when .comma? then return true
    when .v_shi? then return false
    when .v_you? then return false
    when .verbal? then return false # is_linking_verb?(prev, verb)
    when .nquants? then return false
    when .subject?
      return true unless head = prev.prev?
      return false if head.v_shi?
      return true if head.none? || head.unkn? || head.pstops?
    when .none?, .pstops?, .unkn?
      return !find_verb_after(right)
    end

    true
    # find_verb_after(right).try { |x| is_linking_verb?(verb, x) } || true
  end
end
