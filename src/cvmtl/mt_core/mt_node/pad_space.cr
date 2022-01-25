module CV::MTL::PadSpace
  def pad_spaces!(prev : MtNode = self.prev) : MtNode
    # puts [self, self.idx, prev]

    if body = @body
      prev = body.pad_spaces!(prev)
    elsif !@val.empty?
      self.append_space!(prev)
      prev = self
    end

    @succ.try(&.pad_spaces!(prev)) || prev
  end

  def append_space!(prev : MtNode) : Nil
    return if @val.blank?

    if @tag.ndigit? && (prev.tag.plsgn? || prev.tag.mnsgn?)
      @tag = PosTag::String unless prev.prev?(&.ndigit?)
    elsif should_space_before?(prev)
      self.prepend_space!
    end
  end

  def prepend_space!
    if root = @root
      root.prepend_space!
    else
      space = MtNode.new("", val: " ", idx: @idx)
      self.set_prev!(space)
    end
  end

  def should_space_before?(prev : MtNode) : Bool
    return false if prev.val.blank?

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
