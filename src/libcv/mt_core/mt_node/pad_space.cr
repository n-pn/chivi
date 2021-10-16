module CV::MTL::PadSpace
  def pad_spaces!(prev : MtNode = self.prev, head = prev) : MtNode
    if body = @body
      prev = body.pad_spaces!(prev)
    else
      prev = self.append_space!(prev)
    end

    (succ = @succ) ? succ.pad_spaces!(prev) : prev
  end

  def append_space!(prev : MtNode) : MtNode
    if @tag.numlat? && (prev.tag.plsgn? || prev.tag.mnsgn?)
      @tag = PosTag::String unless prev.prev?(&.numlat?)
      self
    elsif should_space_before?(prev)
      self.prepend_space!
      self
    else
      @key.empty? ? prev : self
    end
  end

  def prepend_space!
    if root = @root
      root.prepend_space!
    else
      space = MtNode.new("", val: " ", idx: @idx)
      self.set_prev(space)
    end
  end

  def should_space_before?(prev : MtNode) : Bool
    return false if prev.blank? || @val.blank?

    case @tag
    when .string? then return false if prev.tag.pdeci?
    when .numlat? then return false if prev.tag.plsgn? || prev.tag.mnsgn?
    when .plsgn?  then return false if prev.tag.numlat?
    when .mnsgn?  then return false if prev.tag.numlat?
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
