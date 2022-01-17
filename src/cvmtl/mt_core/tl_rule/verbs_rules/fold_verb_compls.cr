module CV::TlRule
  def fold_verb_compl!(verb : MtNode, compl : MtNode) : MtNode?
    return if verb.v_you? || verb.v_shi?

    if val = MTL::VERB_COMPLS[compl.key]?
      compl.val = val
    else
      case compl.tag
      when .pre_dui?
        return if scan_noun!(compl.succ?)
        compl.val = "đúng"
      when .pre_zai?
        if (succ = scan_noun!(compl.succ?)) && succ.subject?
          return if find_verb_after_for_prepos(succ, skip_comma: true)
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
end
