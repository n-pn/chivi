require "./*"

module MT::Rules
  def foldl_time_full!(time : MtNode)
    time = foldl_time_base!(time)

    case
    when time.prev.ptcl_dep?     then foldl_noun_expr!(time)
    when time.succ.verbal_words? then time
    else                              foldl_objt_full!(objt: time)
    end
  end
end
