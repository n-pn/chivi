module CV::TlRule
  def fold_strings!(node : MtNode) : MtNode
    case node.tag
    when .urlstr? then node = fold_urlstr!(node)
    when .string? then node = fold_string!(node)
    else               node
    end
  end

  def fold_string!(root : MtNode) : MtNode
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

    root.fix_succ!(node)
  end

  private def string_component?(node : MtNode) : Bool
    case node.tag
    when .pdeci?, .atsgn? then node.succ?(&.string?) || false
    when .string?         then true
    else                       false
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

    root.fix_succ!(node)
  end

  private def uri_component?(node : MtNode) : Bool
    case node.tag
    when .string?, .pdeci?, .numlat? then true
    when .puncts?
      case node.key[0]?
      when '%', '?', '-', '=', '~', '#', '@', '/' then true
      else                                             false
      end
    else
      false
    end
  end
end
