module MT::Rules
  def foldl_objt_udep!(objt : MtNode, udep : MtNode)
    noun = NounExpr.new(objt)
    head = foldl_udep_base!(udep)
    noun.tap(&.add_dpmod(head))
  end
end
