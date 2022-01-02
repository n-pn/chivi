module CV::TlRule
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    # puts [verb, prev].colorize.yellow

    case verb
    when .v_shi?, .v_you?
      return fold_left_verb!(verb, prev)
    when .vpro?
      return verb unless (succ = verb.succ?) && succ.verbs?
      verb = fold!(verb, succ, succ.tag, dic: 5)
    end

    flag = 0

    while !verb.verb_object? && (succ = verb.succ?)
      # puts [verb, verb.idx, succ]

      case succ
      when .junction?
        fold_verb_junction!(junc: succ, verb: verb).try { |x| verb = x } || break
      when .uzhe?
        verb = fold_verb_uzhe!(verb, uzhe: succ)
        break
      when .auxils?
        verb = fold_verb_auxils!(verb, succ)
        break if verb.succ? == succ
      when .vdirs?
        verb = fold_verb_vdirs!(verb, succ)
        flag = 1
      when .adj_hao?
        break unless flag == 0 || succ.succ?(&.noun?)
        succ.val = "xong" unless succ.succ?(&.ule?)
        verb = fold!(verb, succ, PosTag::Verb, dic: 4)
      when .adjts?, .verbs?, .preposes?, .uniques?, .space?
        break unless flag == 0
        fold_verb_compl!(verb, succ).try { |x| verb = x } || break
      when .adv_bu?
        break unless succ_2 = succ.succ?

        if succ_2.key == verb.key
          verb = fold_verb_bu_verb!(verb, succ, succ_2)
        elsif succ_2.vdir?
          verb = fold_verb_vdirs!(verb, succ_2)
        else
          fold_verb_compl!(verb, succ).try { |x| verb = x } || break
        end
      when .numeric?
        if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
          verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
          break # TODO: still keep folding?
        end

        if val = PRE_NUM_APPROS[verb.key]?
          succ = fold_number!(succ) if succ.numbers?

          verb = fold_left_verb!(verb.set!(val), prev)
          return verb unless succ.nquants?
          return fold!(verb, succ, succ.tag, dic: 8)
        end

        verb = fold_verb_nquant!(verb, succ, prev)
        prev = nil
        break
      else
        break
      end

      break if verb.succ? == succ
      verb.set!(PosTag::Verb) unless verb.vintr?
    end

    fold_adverb_node!(prev, verb) if prev
    return verb unless succ = verb.succ?

    if succ.suf_noun? || succ.usuo?
      verb = fold_suf_noun!(verb, succ)
      return verb unless succ = verb.succ?
    end

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?

    # puts [verb, verb.succ, verb.succ.succ?]
    verb
  end

  def fold_verb_bu_verb!(verb : MtNode, succ : MtNode, succ_2 : MtNode)
    succ.val = "hay"
    succ_2.val = "không"

    if (succ_3 = succ_2.succ?) && (succ_3.noun? || succ_3.pro_per?)
      succ_2.fix_succ!(succ_3.succ?)
      succ_3.fix_succ!(succ)
      succ_3.fix_prev!(verb)
      tag = PosTag::Vintr
    else
      tag = PosTag::Verb
    end

    fold!(verb, succ_2, tag: tag, dic: 5)
  end

  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      verb = fold_verb_ule!(verb, auxil)
      return verb unless (succ = verb.succ?) && succ.numeric?

      if is_pre_appro_num?(verb)
        succ = fuse_number!(succ) if succ.numeric?
        return fold!(verb, succ, succ.tag, dic: 4)
      end

      return fold_verb_nquant!(verb, succ, has_ule: true)
    when .ude2?
      return verb unless (succ_2 = auxil.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      auxil.set!("mà")
      fold!(verb, succ_2, PosTag::Verb, dic: 5)
    when .ude3?
      fold_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    else
      verb
    end
  end

  def fold_verb_vdirs!(verb : MtNode, vdir : MtNode) : MtNode
    case vdir.key
    when "起"  then vdir.val = "lên"
    when "进"  then vdir.val = "vào"
    when "来"  then vdir.val = "tới"
    when "过去" then vdir.val = "qua"
    when "下去" then vdir.val = "xuống"
    when "下来" then vdir.val = "lại"
    when "起来" then vdir.val = "lên"
    end

    fold!(verb, vdir, PosTag::Verb, dic: 5)
  end

  def fold_verb_compl!(verb : MtNode, compl : MtNode) : MtNode?
    return if verb.v_you? || verb.v_shi?

    if val = MTL::VERB_COMPLS[compl.key]?
      compl.val = val
    else
      case compl.tag
      when .pre_dui?
        return if (succ = compl.succ?) && (succ.nouns? || succ.pro_per?)
        compl.val = "đúng"
      when .pre_zai?
        if succ = scan_noun!(compl.succ?)
          return if find_verb_after(succ)
        end

        compl.val = "ở"
      when .space?
        return unless compl.key == "中"
        if compl.succ?(&.ule?)
          compl.val = "trúng"
        else
          compl.val = "đang"
          return fold!(verb, compl, PosTag::VerbPhrase, 9, flip: true)
        end
      else
        return
      end
    end

    fold!(verb, compl, PosTag::Verb, dic: 6)
  end

  def fold_left_verb!(node : MtNode, prev : MtNode?)
    return node unless prev && prev.adverbs?
    fold_adverb_node!(prev, node)
  end

  def fold_verb_uzhe!(prev : MtNode, uzhe : MtNode, succ = uzhe.succ?) : MtNode
    uzhe.val = ""

    if succ && succ.verbs?
      # succ = fold_verbs!(succ)
      fold!(prev, succ, PosTag::Verb, dic: 5)
    else
      fold!(prev, uzhe, PosTag::Verb, dic: 6)
    end
  end
end
