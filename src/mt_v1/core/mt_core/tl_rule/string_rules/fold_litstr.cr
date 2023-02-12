module M1::TlRule
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
end
