module MT::Rules
  def foldl_objt_udep!(objt : MtNode, udep : MtNode, head = udep.prev)
    return objt if head.punctuations?

    head = foldl_udep_base!(udep, head)

    noun = NounExpr.new(objt)
    noun.tap(&.add_dpmod(head))
  end
end
