module M1::TlRule
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
    return false if node.key.empty?

    case node.tag
    when .litstr?, .urlstr?, .ndigit? then true
    when .puncts?
      {'%', '?', '-', '=', '~', '#', '@', '/', '.'}.includes?(node.key[0]?)
    else
      node.key !~ /[^a-zA-Z]/
    end
  end
end
