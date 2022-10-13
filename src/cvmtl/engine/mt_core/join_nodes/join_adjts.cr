module MT::Core
  # join adjective to larger non-adjectival structures
  def join_adjt!(adjt : BaseNode) : BaseNode
    adjt = link_adjt!(adjt)
    # TODO: join adjt with other type
    adjt
  end

  # join multi adjective phrases together by bond words
  def link_adjt!(adjt : BaseNode)
    adjt = fuse_adjt!(adjt)

    tag, pos = MapTag::Aform

    while (prev = adjt.prev?) && prev.is_a?(BaseTerm)
      if prev.adjt_words?
        prev = fuse_adjt!(prev)
        pos |= MtlPos::AtHead if prev.at_tail?
        adjt = BasePair.new(prev, adjt, tag, pos, flip: prev.at_tail?)

        next
      end

      case prev.tag
      when .wd_he2?, .wd_yu3?
        prev = fix_he3yu2!(prev)
        break unless prev.bond_word?
      when .cenum?
        prev.val = ","
      else
        break unless prev.bond_word?
      end

      case head = prev.prev
      when .adjt_words?
        head = fuse_adjt!(head)
      else
        # FIXME: check for other type of modifier phrase
        break
      end

      pos |= MtlPos::AtHead if prev.at_tail? || adjt.at_head?
      head = BasePair.new(head, prev, tag, pos, flip: pos.at_head?)
      adjt = BasePair.new(head, adjt, tag, pos, flip: pos.at_head?)
    end

    adjt
  end

  # join adjectives + adverbs together, resulting a single adjective form
  def fuse_adjt!(adjt : BaseNode, prev = adjt.prev)
    # TODO:
    # - mark adjective as reduplication

    tag, pos = MapTag.make(:aform)

    while prev.is_a?(BaseTerm)
      break unless prev.adjt_words? || prev.maybe_adjt?
      adjt = BasePair.new(prev, adjt, tag: tag, pos: pos, flip: !prev.at_head?)
      prev = prev.prev
    end

    while prev.is_a?(BaseTerm)
      case prev
      when .adv_bu4?
        adjt = join_adjt_bu4!(adjt, prev)
        prev = adjt.prev
        next
      when .wd_hao?
        prev.val = "thật"
      when .maybe_advb?
        prev.as_advb!(prev.alt)
      else
        break unless prev.advb_words?
      end

      adjt = BasePair.new(prev, adjt, tag: tag, pos: pos, flip: prev.at_tail?)
      prev = adjt.prev
    end

    adjt
  end

  def join_adjt_bu4!(adjt : BaseNode, bu4 = adjt.prev, prev = bu4.prev)
    tag, pos = MapTag.make(:aform)

    if (prev.adjt_words? || prev.maybe_adjt?) && (head = prev.prev) && head.tag.adv_bu4?
      prev = BasePair.new(head, prev, tag, pos)
      adjt = BasePair.new(bu4, adjt, tag, pos)
      return BasePair.new(prev, adjt, tag, pos)
    end

    unless adjt.is_a?(BaseTerm) && prev.is_a?(BaseTerm) && adjt.key == prev.key
      return BasePair.new(bu4, adjt, tag, pos)
    end

    prev.as(BaseTerm).val = "hay"
    prev = BasePair.new(prev, bu4, flip: true)

    BasePair.new(prev, adjt, tag, pos, flip: true)
  end
end
