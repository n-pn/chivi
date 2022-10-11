module MT::TlRule
  def fold_adjt_adv_bu!(adjt : BaseNode, adv : BaseNode, prev : BaseNode?)
    return unless tail = adv.succ?

    if prev && prev.adv_bu4?
      return fold!(prev, tail, MapTag::Aform)
    end

    return unless tail.key == adjt.key

    adjt = fold_adj_adv!(adjt, prev) if prev
    adv.val = "hay"
    fold!(adjt, tail.set!("không"), MapTag::Aform)
  end
end
