module MT::Rules
  def foldr_name_base!(name : MtNode)
    case name
    when .human_name? then foldr_human_name!(name)
    when .space_name? then foldr_space_name!(name)
    else                   foldr_other_name!(name)
    end
  end

  def foldr_human_name!(name : MtNode)
    head = name.prev

    # FIXME: check if succ.key == name.key because it is obviously not combinable

    while succ = name.succ
      case succ
      when .middot?
        tail = succ.succ
        break unless tail.name_words?
        succ.as(MonoNode).val = " "

        name = TrioNode.new(name, succ, tail)
      when .cenum?
        tail = succ.succ
        break unless tail.human_name?

        succ.as(MonoNode).val = ","
        name = tail
      when .human_name?
        name = succ
      when .honor?
        name = PairNode.new(name, succ, name.tag, name.pos)
      else
        break
      end
    end

    foldr_name_list!(head.succ, tail: name, succ: succ)
  end

  def foldr_space_name!(name : MtNode)
    head = name.prev
    flip = true

    while succ = name.succ
      case succ
      when .cenum?
        tail = succ.succ
        break unless tail.space_name?

        succ.as(MonoNode).val = ","
        name = tail
        flip = false
      when .space_name?
        name = succ
      when .loc_sf?
        tag, pos = PosTag.make(:place_name)
        name = PairNode.new(name, succ, tag, pos)
      when .org_sf?
        tag, pos = PosTag.make(:insti_name)
        name = PairNode.new(name, succ, tag, pos)
      else
        break
      end
    end

    foldr_name_list!(head.succ, tail: name, succ: succ, flip: flip)
  end

  def foldr_other_name!(name : MtNode)
    head = name.prev

    while succ = name.succ
      case succ
      when .cenum?
        tail = succ.succ
        break unless tail.other_names?
        succ.as(MonoNode).val = ","
        name = tail
      when .other_names?
        name = succ
      else
        break
      end
    end

    foldr_name_list!(head.succ, tail: name, succ: succ)
  end

  private def foldr_name_list!(head : MtNode, tail : MtNode, succ : MtNode, flip = false)
    if succ.ptcl_etcs? && (head != tail || etcs_is_particle?(node: succ))
      if head != tail
        # puts [head, tail, "has_udeng"]
        # head, _tail = flip_name_list_smart!(head, tail)
      end

      tail = succ.tap(&.as(MonoNode).fix_val!)
    elsif flip && head != tail
      # puts [head, tail, "should_flip"]
      # head, tail = flip_name_list_full!(head, tail)
    end

    case
    when head == tail      then head
    when head.succ == tail then PairNode.new(head, tail, head.tag, head.pos)
    else                        SeriNode.new(head, tail, head.tag, head.pos)
    end
  end

  @[AlwaysInline]
  private def etcs_is_particle?(node : MtNode)
    !(node.ptcl_deng1? || node.ptcl_deng2?) || !node.succ?(&.object?)
  end

  private def flip_name_list_full!(head : MtNode, tail : MtNode)
    prev = head.prev
    succ = tail.succ

    while node = tail.prev?
      flip_node!(node, tail)
      break if node == head
    end

    {prev.succ, succ.prev}
  end

  private def flip_name_list_smart!(head : MtNode, tail : MtNode)
    prev = head.prev
    succ = tail.succ

    while node = tail.prev?
      if node.place_name? && tail.insti_name?
        tail = PairNode.new(node, tail, tail.tag, tail.pos)
      else
        tail = node
      end

      break if node == head
    end

    {prev.succ, succ.prev}
  end

  private def flip_node!(head : MtNode, tail : MtNode) : Nil
    head.fix_succ!(tail.succ?)
    tail.fix_prev!(head.prev?)
    tail.fix_succ!(head)
  end
end
