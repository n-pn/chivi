module CV::MTL::Grammars
  def fix_string(node : MtNode) : MtNode
    while succ = node.succ
      case succ.tag
      when .pdeci?, .atsgn?, .string?
        node = succ.tap(&.fuse_left!(node.val))
      else
        break
      end
    end

    node
  end
end
