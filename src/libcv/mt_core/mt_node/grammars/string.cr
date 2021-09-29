module MTL::Grammars
  def fix_string : self
    return self unless node = @succ

    key_io = String::Builder.new(@key)
    val_io = String::Builder.new(@val)

    while node.string_component?
      key_io << node.key
      val_io << node.val
      break unless node = node.succ?
    end

    return self if node == @succ

    @key = key_io.to_s
    @val = val_io.to_s

    fix_succ(node)
  end

  def string_component?
    case @tag
    when .pdeci?, .atsgn?, .string? then true
    else                                 false
    end
  end
end
