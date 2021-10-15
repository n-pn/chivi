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
      @key.blank? || @val.blank? ? prev : self
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
    return false if prev.val.blank? || @val.blank?

    case @tag
    when .colon?  then return false
    when .middot? then return true
    when .ptitle?
      return false unless prev.should_space_after?
      return @key[0] == '-' ? false : true
    when .plsgn?, .mnsgn?
      return false if prev.tag.numlat?
    when .numlat?
      return false if prev.tag.plsgn? || prev.tag.mnsgn?
      # when .pdash?  then return !prev.tag.puncts?
    when .quotecl?, .parencl?, .brackcl?, .titlecl?,
         .comma?, .penum?, .pstop?, .pdeci?,
         .smcln?, .exmark?, .qsmark?, .ellip?,
         .tilde?, .squanti?, .perct?
      return prev.tag.colon?
    when .quoteop?, .parenop?, .brackop?, .titleop?
      return prev.should_space_after?
    when .puncts?
      case prev.tag
      when .colon?, .comma?, .pstop? then return true
      else                                return !prev.tag.puncts?
      end
    when .string?
      return false if prev.tag.pdeci?
    end

    prev.should_space_after?
  end

  def should_space_after? : Bool
    case @tag
    when .quoteop?, .parenop?, .brackop?, .titleop?
      false
    else
      true
    end
  end
end
