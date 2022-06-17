class MtlV2::BaseNode
  def to_int?
    case @tag
    when .ndigit? then @val.to_i64?
    when .nhanzi? then MtUtil.to_integer(@key)
    else               nil
    end
  rescue err
    File.open("tmp/nhanzi-error.txt", "a", &.puts(@key))
    nil
  end

  def maybe_verb? : Bool
    succ = self
    while succ
      # puts [succ, "maybe_verb", succ.verbal?]
      case succ
      when .verbal?, .vmodals? then return true
      when .adverbial?, .comma?, pro_ints?, .conjunct?, .temporal?
        succ = succ.succ?
      else return false
      end
    end

    false
  end

  def maybe_adjt? : Bool
    return !@succ.try(&.maybe_verb?) if @tag.ajad?
    @tag.adjective? || @tag.adverbial? && @succ.try(&.maybe_adjt?) || false
  end

  def last_child : BaseNode?
    return nil unless body = @body

    while succ = body.succ?
      body = succ
    end

    body
  end

  def starts_with?(inp : String | Char)
    raise "fatal error!" if @body == self
    @body.try(&.starts_with?(inp)) || @key.starts_with?(inp)
  end

  def ends_with?(key : String | Char)
    return @key.ends_with?(key) unless child = self.last_child
    child.ends_with?(key)
  end

  def key_in?(*keys : String)
    keys.includes?(@key)
  end

  def key?(key : String)
    @key === key
  end

  def dig_key?(key : String | Char) : self | Nil
    return @key.includes?(key) ? self : nil unless child = @body

    while child
      child = child.succ? unless found = child.dig_key?(key)
      return found
    end
  end

  def each(&block : self ->)
    block.call(self) unless body = @body

    while body
      body.each(&block)
      body = body.succ?
    end
  end
end
