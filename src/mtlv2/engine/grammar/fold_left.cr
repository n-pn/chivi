require "./fold_left/*"

module MtlV2::MTL
  def fold_left!(curr : BaseNode, left : BaseNode?) : BaseNode
    return curr unless left

    case curr
    when Nominal then MTL.fold_noun_left!(curr, left)
    else              curr
    end
  end

  extend self
end
