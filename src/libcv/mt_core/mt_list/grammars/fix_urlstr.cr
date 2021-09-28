module CV::MTL::Grammars
  def fix_urlstr(node : MtNode) : MtNode
    while succ = node.succ?
      case succ.tag
      when .string?, .pdeci?, .numlat?
        node = succ.tap(&.fuse_left!(node.val))
      else
        case succ.key[0]
        when '%', '?', '-', '=', '~', '#', '@', '/'
          node = succ.tap(&.fuse_left!(node.val))
        else
          break
        end
      end
    end

    node
  end
end
