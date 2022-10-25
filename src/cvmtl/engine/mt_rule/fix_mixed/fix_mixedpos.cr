module MT::Core
  def fix_mixedpos!(node : MonoNode)
    case node
    when .polysemy? then fix_polysemy!(node)
    when .uniqword? then fix_uniqword!(node)
    when .qt_temp?  then fix_qttemp!(node)
    when .vauxil?   then fix_vauxil!(node)
    when .vcompl?   then fix_vcompl!(node)
    else                 node
    end
  end

  def fix_mixedpos!(node : MtNode)
    Log.warn { "this should not happen!" }
    node
  end
end
