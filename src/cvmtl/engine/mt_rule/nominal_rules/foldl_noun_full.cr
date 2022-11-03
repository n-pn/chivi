module MT::Rules
  def foldl_noun_full!(noun : MtNode)
    noun = foldl_noun_expr!(noun)
    # puts [noun, noun.prev?]

    # FIXME: since this only check for bond word, we can check for those exception in link_noun functon
    # thus no need to resolve mixedpos in this step
    prev = noun.prev
    prev = fix_mixedpos!(prev) if prev.mixedpos?

    noun = foldr_noun_join!(noun, junc: prev) if prev.join_word?
    foldl_objt_full!(noun)
  end
end
