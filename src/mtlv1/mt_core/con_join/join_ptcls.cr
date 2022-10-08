module CV::TlRule
  def join_udev!(udev : BaseNode)
    raise "udev should be BaseTerm" unless udev.is_a?(BaseTerm)

    tag = MtlTag::DvPhrase
    pos = MtlPos::AtTail

    inactive = true

    case head = udev.prev
    when .adjt_words?
      head = join_adjt!(head)
    when .verb_words?
      # TODO: convert verb to advb
      udev.val = "một cách"
      inactive = false
    when .onomat?, .nquants?
      udev.inactivate!
    when .common_nouns?
      raise "Expected v_you!" unless (vyou = head.prev?) && vyou.v_you?
      head = BasePair.new(vyou, head, PosTag::Adjt, dic: 4, flip: false)
    end

    udev.inactivate! if inactive # mark udev as invisible
    BasePair.new(head, udev, tag: PosTag.new(tag, pos), dic: 6, flip: true)
  end

  def join_udep!(udep : BaseNode)
    raise "udep should be BaseTerm" unless udep.is_a?(BaseTerm)

    tag = MtlTag::DcPhrase
    pos = MtlPos::AtTail

    head = join_word!(udep.prev)
    if head.ktetic?
      udep.val = "của"
    else
      udep.inactivate!
    end

    BasePair.new(head, udep, PosTag.new(tag, pos), flip: true)
  end
end
