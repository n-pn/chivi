module CV::TlRule
  extend self

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

  def string_component?(node : MtNode) : Bool
    case node.tag
    when .pdeci?, .atsgn? then node.succ?(&.string?) || false
    when .string?         then true
    else                       false
    end
  end
end
