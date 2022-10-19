module MT::Core
  def join_udev!(udev : MtNode)
    raise "udev should be MonoNode" unless udev.is_a?(MonoNode)

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
      head = join_noun!(head)
      raise "Expected v_you!" unless (vyou = head.prev?) && vyou.v_you?
      tag, pos = PosTag::Adjt
      head = PairNode.new(vyou, head, tag, pos, flip: false)
    end

    udev.inactivate! if passive # mark udev as invisible
    PairNode.new(head, udev, tag, pos, flip: true)
  end
end
