module CV::TlRule
  extend self

  def fuse_urlstr!(root : MtNode) : MtNode
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

  def uri_component?(node : MtNode) : Bool
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
