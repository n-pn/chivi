module MTL::Grammars
  def fuse_urlstr : self
    return self unless node = @succ

    key_io = String::Builder.new(@key)
    val_io = String::Builder.new(@val)

    while node.uri_component?
      key_io << node.key
      val_io << node.val
      break unless node = node.succ?
      puts node
    end

    return self if node == @succ

    @key = key_io.to_s
    @val = val_io.to_s

    puts [@key, @val]

    fix_succ(node)
  end

  def uri_component?
    case @tag
    when .string?, .pdeci?, .numlat? then true
    when .puncts?
      case @key[0]
      when '%', '?', '-', '=', '~', '#', '@', '/' then true
      else                                             false
      end
    else
      false
    end
  end
end
