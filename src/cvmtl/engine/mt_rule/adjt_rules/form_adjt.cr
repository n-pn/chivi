module MT::Core
  # join adjectives + adverbs together, resulting a single adjective form
  def form_adjt!(adjt : MtNode, prev = adjt.prev)
    # TODO:
    # - mark adjective as reduplication

    tag, pos = PosTag.make(:amix)

    while prev.is_a?(MonoNode)
      break unless prev.adjt_words? # amix?|| prev.maybe_adjt?
      adjt = PairNode.new(prev, adjt, tag: tag, pos: pos, flip: !prev.at_head?)
      prev = prev.prev
    end

    while prev.is_a?(MonoNode)
      case prev
      # when .adv_you?
      # FIXME: handle 又
      when .adv_bu4?
        adjt = fold_adjt_bu4!(adjt, prev)
        prev = adjt.prev
        next
      when .hao_word?
        prev.val = "thật"
      when .maybe_advb?
        prev.as_advb!(prev.alt)
      else
        break unless prev.advb_words?
      end

      adjt = PairNode.new(prev, adjt, tag: tag, pos: pos, flip: prev.at_tail?)
      prev = adjt.prev
    end

    adjt
  end
end
