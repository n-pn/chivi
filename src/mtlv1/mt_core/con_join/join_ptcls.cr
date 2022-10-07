module CV::TlRule
  def join_udev!(udev : BaseNode)
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
      udev.as_empty!
    when .common_noun?
      raise "Expected v_you!" unless (vyou = head.prev?) && vyou.v_you?
      head = BasePair.new(vyou, head, PosTag::Adjt, dic: 4, flip: false)
    end

    udev.inactivate! if inactive # mark udev as invisible

    BasePair.new(head, udev, ptag: PosTag.new(tag, pos), dic: 6, flip: true)
  end
end
