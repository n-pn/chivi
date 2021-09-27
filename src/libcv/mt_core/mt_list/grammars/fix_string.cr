module CV::MTL::Grammars
  def fix_string!(node : MtNode) : MtNode
    while succ = node.succ
      case succ.tag
      when .pdeci?, .string?
        node = succ.tap(&.fuse_left!(node.val))
      else
        break
      end
    end

    if node.key =~ /^\d+$/ || node.key =~ /^\d+\.\d+$/
      node.update!(tag: PosTag::Number)
      return fix_number!(node)
    end

    # TODO: handle `.jpg`

    node
  end

  def fix_urlstr!(node : MtNode) : MtNode
    while succ = node.succ
      case succ.tag
      when .string?, .pdeci?
        node = succ.tap(&.fuse_left!(node.val))
        next
      else
        break unless succ.tag.puncts?
      end

      case succ.key[0]
      when '%', '?', '-', '=', '~', '#', '@', '/'
        node = succ.tap(&.fuse_left!(node.val))
        next
      else
        break
      end
    end

    node
  end
end
