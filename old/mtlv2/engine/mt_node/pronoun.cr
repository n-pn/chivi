class ProZhe
  def heal!(succ = @succ) : Nil
    case succ
    when Nil, Prepos
      @val = "cái này"
    when Verbal
      @val = "đây"
    when Comma
      if (zhe2 = succ.succ?) && zhe2.is_a?(ProZhe)
        zhe2.heal!
        @val = zhe2.val
      end
    else
      @val = "giờ" if @prev.is_a?(Nominal)
    end
  end

  def noun_prefix?
    false
  end
end

class ProNa1
  def heal!(succ = @succ) : Nil
    @val = "vậy" unless succ.is_a?(Verbal)
  end

  def noun_prefix?
    false
  end
end
