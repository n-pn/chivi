module MT::Rules
  def foldl_udev_full!(udev : MtNode)
    raise "udev should be MonoNode" unless udev.is_a?(MonoNode)

    tag = MtlTag::DvPhrase
    pos = udev.ptcl_dep? ? MtlPos::AtHead : MtlPos::AtTail

    passive = true

    case head = udev.prev
    when .adjt_words?
      head = foldl_adjt_full!(head)
    when .verbal_words?
      # TODO: convert verb to advb
      udev.val = "một cách"
      passive = false
    when .onomat?, .nquants?
      udev.skipover!
    when .common_nouns?
      head = foldl_noun_full!(head)
      unless (vyou = head.prev?) && vyou.v_you?
        raise "Expected v_you #{vyou}!"
      end

      tag, pos = PosTag.make(:adjt)
      head = PairNode.new(vyou, head, tag, pos, flip: false)
    end

    udev.skipover! if passive # mark udev as invisible
    PairNode.new(head, udev, tag, pos, flip: true)
  end
end
