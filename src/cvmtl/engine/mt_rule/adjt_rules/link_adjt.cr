module MT::Core
  # join multi adjective phrases together by bond words
  def link_adjt!(adjt : MtNode)
    adjt = form_adjt!(adjt)

    tag, pos = PosTag.make(:amix)

    while (prev = adjt.prev?) && prev.is_a?(MonoNode)
      if prev.adjt_words?
        prev = form_adjt!(prev)
        pos |= MtlPos::AtHead if prev.at_tail?
        adjt = PairNode.new(prev, adjt, tag, pos, flip: prev.at_tail?)

        next
      end

      case prev.tag
      when .he2_word?, .yu3_word?
        prev = fix_he3yu2!(prev)
        break unless prev.bind_word?
      when .cenum?
        prev.val = ","
      else
        break unless prev.bind_word?
      end

      case head = prev.prev
      when .adjt_words?
        head = form_adjt!(head)
      else
        # FIXME: check for other type of modifier phrase
        break
      end

      pos |= MtlPos::AtHead if prev.at_tail? || adjt.at_head?
      head = PairNode.new(head, prev, tag, pos, flip: pos.at_head?)
      adjt = PairNode.new(head, adjt, tag, pos, flip: pos.at_head?)
    end

    adjt
  end
end
