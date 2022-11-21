module MT::TlRule
  def fold_verb_compl!(verb : MtNode, compl : MtNode) : MtNode?
    return if verb.v_you? || verb.v_shi? || !compl.maybe_cmpl?

    case compl.tag
    when .prep_dui?
      return if scan_noun!(compl.succ?)
      compl.val = "đúng"
    when .prep_zai?
      # if (succ = scan_noun!(compl.succ?)) && succ.content?
      #   # puts [succ, "pre_zai"]
      #   return if find_verb_after_for_prepos(succ, skip_comma: true)
      # end

      compl.val = "ở"
    when .locat?
      return unless compl.key == "中"
      if compl.succ?(&.ptcl_le?)
        compl.val = "trúng"
      else
        return fold!(verb, compl.set!("đang"), verb.tag, 9, flip: true)
      end
    else
      return
    end
    fold!(verb, compl, PosTag::Verb)
  end
end
