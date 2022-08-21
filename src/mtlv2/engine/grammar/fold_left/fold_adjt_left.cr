require "./fold_advb_left"

module MtlV2::MTL
  def fold_adjt_left!(curr : Adjective, left : BaseNode, lvl = 0)
    while left.is_a?(Adjective)
      if curr.is_a?(AdjtExpr)
        curr.add_head(left)
      else
        curr = AdjtExpr.new(left, curr)
      end

      break unless left = curr.prev?
    end

    return curr unless left
    if left.is_a?(Adverbial)
      advb = fold_advb_left!(left, left.prev?)
      curr = AdjtForm.new(curr, advb)
      # return curr unless left = curr.prev?
    end

    # TODO: fold with conjunction?
    curr
  end
end
