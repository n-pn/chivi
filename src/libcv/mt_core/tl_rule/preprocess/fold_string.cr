module CV::TlRule
  def fold_strings!(node : MtNode) : MtNode
    if node.litstr?
      fold_litstr!(node)
    elsif node.key.starts_with?("http")
      fold_urlstr!(node)
    else
      node
    end
  end

  def fold_litstr!(root : MtNode) : MtNode
    return root unless node = root.succ?

    key_io = String::Builder.new(root.key)
    val_io = String::Builder.new(root.val)

    while string_component?(node)
      key_io << node.key
      val_io << node.val
      break unless node = node.succ?
    end

    return root if node == root.succ?

    root.key = key_io.to_s
    root.val = val_io.to_s

    root.tap(&.fix_succ!(node))
  end

  private def string_component?(node : MtNode) : Bool
    case node.tag
    when .pdeci?, .atsign? then node.succ?(&.litstr?) || false
    when .litstr?          then true
    else                        false
    end
  end

  def fold_urlstr!(root : MtNode) : MtNode
    return root unless node = root.succ?

    key_io = String::Builder.new(root.key)
    val_io = String::Builder.new(root.val)

    while uri_component?(node)
      key_io << node.key
      val_io << node.val
      break unless node = node.succ?
    end

    return root if node == root.succ?

    root.key = key_io.to_s
    root.val = val_io.to_s

    root.tag = PosTag::Fixstr
    root.tap(&.fix_succ!(node))
  end

  private def uri_component?(node : MtNode) : Bool
    case node.tag
    when .litstr?, .ndigit? then true
    when .puncts?
      {'%', '?', '-', '=', '~', '#', '@', '/'}.includes?(node.key[0]?)
    else
      node.key !~ /[^a-zA-Z]/
    end
  end

  def fold_atsign!(head : MtNode, tail = head)
    key_io = String::Builder.new

    while tail = tail.succ?
      break if tail.key == " "
      return head if tail.puncts?
      key_io << tail.key
    end

    return head unless tail

    key = key_io.to_s
    val = TextUtil.titleize(MtCore.cv_hanviet(key, false))

    key = "#{head.key}#{key}#{tail.key}"

    if (prev = head.prev?) && prev.key == " "
      head = prev
      key = prev.key + key
    end

    MtNode.new(key, "@#{val}", PosTag::Person, dic: 2, idx: head.idx).tap do |new_node|
      new_node.fix_prev!(head.prev?)
      new_node.fix_succ!(tail.succ?)
    end
  end
end
