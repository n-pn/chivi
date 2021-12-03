module CV::MTL::PadSpace
  def pad_spaces!(prev : MtNode = self.prev) : MtNode
    if body = @body
      prev = body.pad_spaces!(prev)
    else
      prev = self.append_space!(prev)
    end

    (succ = @succ) ? succ.pad_spaces!(prev) : prev
  end

  def append_space!(prev : MtNode) : MtNode
    return prev if @key.empty? || @val.empty?

    if @tag.ndigit? && (prev.tag.plsgn? || prev.tag.mnsgn?)
      @tag = PosTag::String unless prev.prev?(&.ndigit?)
    elsif should_space_before?(prev)
      self.prepend_space!
    end

    self
  end

  def prepend_space!
    if root = @root
      root.prepend_space!
    else
      space = MtNode.new("", val: " ", idx: @idx)
      space.fix_prev!(@prev)
      space.fix_succ!(self)
    end
  end

  def should_space_before?(prev : MtNode) : Bool
    case @tag
    when .string? then return false if prev.tag.pdeci?
    when .ndigit? then return false if prev.tag.plsgn? || prev.tag.mnsgn?
    when .plsgn?  then return false if prev.tag.ndigit?
    when .mnsgn?  then return false if prev.tag.ndigit?
    when .colon?  then return false
    when .middot? then return true
    when .ptitle?
      return false if prev.popens?
      return @key[0] == '-' ? false : true
    when .popens? then return !prev.popens?
    when .puncts?
      case @tag
      # when .pdash?  then return !prev.tag.puncts?
      when .pstops?, .comma?, .penum?,
           .pdeci?, .ellip?, .tilde?,
           .perct?, .squanti?
        return prev.tag.colon?
      else
        case prev.tag
        when .colon?, .comma?, .pstop? then return true
        else                                return !prev.puncts?
        end
      end
    end

    !prev.popens?
  end
end
