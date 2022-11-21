module MT::Rules
  def foldl_locat_full!(locat : MtNode)
    case locat
    when .loc_hou4?
      return foldl_local_hou4!(locat) # if locat.succ?(&.boundary?)
    end

    foldl_noun_full!(locat)
  end

  def foldl_local_hou4!(locat : MtNode, prev = locat.prev)
    prev = foldl_once!(prev)

    case prev
    when NounExpr
      prev.tap(&.add_locat(locat))
    when .all_nouns?
      tag, pos = PosTag.make(:posit)
      NounPair.new(prev, locat, tag, pos, flip: true)
    else
      return foldl_noun_full!(locat) if prev.unreal?
      tag, pos = PosTag.make(:timeword)
      locat.as(MonoNode).val = "sau khi"
      PairNode.new(prev, locat, tag, pos, flip: true)
    end
  end
end
