module MT::Core
  def join_udev!(udev : BaseNode)
    raise "udev should be BaseTerm" unless udev.is_a?(BaseTerm)

    tag = MtlTag::DvPhrase
    pos = MtlPos::AtTail

    passive = true

    case head = udev.prev
    when .adjt_words?
      head = join_adjt!(head)
    when .verb_words?
      # TODO: convert verb to advb
      udev.val = "một cách"
      passive = false
    when .onomat?, .nquants?
      udev.inactivate!
    when .common_nouns?
      head = join_noun_1!(head)
      raise "Expected v_you!" unless (vyou = head.prev?) && vyou.v_you?
      tag, pos = MapTag::Adjt
      head = BasePair.new(vyou, head, tag, pos, flip: false)
    end

    udev.inactivate! if passive # mark udev as invisible
    BasePair.new(head, udev, tag, pos, flip: true)
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

    BasePair.new(head, udep, tag, pos, flip: true)
  end
end
