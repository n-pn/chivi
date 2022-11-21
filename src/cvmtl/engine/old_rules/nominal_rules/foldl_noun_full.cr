module MT::Rules
  def foldl_noun_full!(noun : MtNode)
    noun = foldl_noun_base!(noun)
    foldl_objt_full!(noun)
  end
end
