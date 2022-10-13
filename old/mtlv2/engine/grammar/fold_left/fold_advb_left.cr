module MT::MTL
  def fold_advb_left!(curr : Adverbial, left : Adverbial)
    curr = AdvbExpr.new(left, curr)
    # puts [curr, curr.prev?].colorize.yellow

    while left = curr.prev?
      break unless left.is_a?(Adverbial)
      curr.add_head(left)
    end

    curr
  end

  def fold_advb_left!(curr : Adverbial, left : MtNode?)
    curr
  end
end
